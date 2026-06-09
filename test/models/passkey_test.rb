require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  # A stand-in for what the webauthn gem returns from `from_get` / `from_create`, so the
  # specs cover *our* sign-in/persist logic without driving a real authenticator.
  FakeCredential = Struct.new(:id, :public_key, :sign_count, :outcome) do
    def verify(*)
      raise WebAuthn::Error, "rejected" if outcome == :error

      true
    end
  end

  describe "passkey login (#verify)" do
    it "stays signed out when there is no challenge cookie" do
      priya.passkeys.create!(external_id: "cred-1", public_key: "pk", sign_count: 0)
      fake = FakeCredential.new("cred-1", "pk", 4, :ok)

      result = stub_credential(:from_get, fake) { login.passkey.verify({}) }

      expect(result).to eq(false)
      expect(login.signed_in?).to eq(false)
    end

    it "signs the user in and bumps the sign count on a valid assertion" do
      passkey = priya.passkeys.create!(external_id: "cred-1", public_key: "pk", sign_count: 0)
      stash_challenge
      fake = FakeCredential.new("cred-1", "pk", 9, :ok)

      result = stub_credential(:from_get, fake) { login.passkey.verify({}) }

      expect(result).to eq(true)
      expect(login.user).to eq(priya)
      expect(passkey.reload.sign_count).to eq(9)
    end

    it "rejects an assertion that fails verification" do
      priya.passkeys.create!(external_id: "cred-1", public_key: "pk", sign_count: 0)
      stash_challenge
      fake = FakeCredential.new("cred-1", "pk", 9, :error)

      result = stub_credential(:from_get, fake) { login.passkey.verify({}) }

      expect(result).to eq(false)
      expect(login.signed_in?).to eq(false)
    end

    it "rejects an unknown credential" do
      stash_challenge
      fake = FakeCredential.new("never-seen", "pk", 9, :ok)

      result = stub_credential(:from_get, fake) { login.passkey.verify({}) }

      expect(result).to eq(false)
      expect(login.signed_in?).to eq(false)
    end
  end

  describe "passkey registration (#register)" do
    it "refuses when no one is signed in" do
      stash_challenge
      fake = FakeCredential.new("cred-1", "pk", 0, :ok)

      result = stub_credential(:from_create, fake) { login.passkey.register({}) }

      expect(result).to eq(false)
    end

    it "refuses without a challenge cookie" do
      sign_in(priya)
      fake = FakeCredential.new("cred-1", "pk", 0, :ok)

      result = stub_credential(:from_create, fake) { login.passkey.register({}) }

      expect(result).to eq(false)
    end

    it "persists a passkey for the signed-in user" do
      sign_in(priya)
      stash_challenge
      fake = FakeCredential.new("cred-new", "pk-new", 0, :ok)

      result = nil
      expect {
        result = stub_credential(:from_create, fake) { login.passkey.register({}, nickname: "Laptop") }
      }.to change { priya.passkeys.count }.by(1)

      expect(result).to eq(true)
      expect(priya.passkeys.last.external_id).to eq("cred-new")
    end
  end

  private

  def login
    @login ||= Login.new(cookie_jar)
  end

  def cookie_jar
    @cookie_jar ||= ActionDispatch::TestRequest.create.cookie_jar
  end

  def priya
    users.priya
  end

  def stash_challenge
    cookie_jar.encrypted[:webauthn_challenge] = "challenge-bytes"
  end

  def sign_in(user)
    cookie_jar.encrypted[:user_id] = user.id
  end

  # Swap a WebAuthn::Credential class method for the block, then restore it (minitest 6
  # ships no mock/stub).
  def stub_credential(name, value)
    original = WebAuthn::Credential.method(name)
    WebAuthn::Credential.define_singleton_method(name) { |*, **| value }
    yield
  ensure
    WebAuthn::Credential.define_singleton_method(name) { |*args, **kwargs| original.call(*args, **kwargs) }
  end
end
