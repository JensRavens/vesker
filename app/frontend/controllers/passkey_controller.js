import { Controller } from "@hotwired/stimulus";
import { get, create } from "@github/webauthn-json";
import { Turbo } from "@hotwired/turbo-rails";

// Drives passkey login (discoverable, no email) and passkey registration. The WebAuthn
// API calls happen here because navigator.credentials.* must run in JS; the *result* is
// just data, so we drop it into a hidden field and submit a normal Turbo form — the
// server replies with a shimmer navigation, exactly like the email-code flow.
export default class extends Controller {
  static targets = ["form", "credential"];
  static values = {
    options: Object,
    mode: String,
  };

  connect() {
    if (this.modeValue === "conditional") this.startConditional();
  }

  disconnect() {
    this.abortController?.abort();
  }

  // Conditional mediation: passkeys surface as autofill suggestions on the email field.
  // The promise resolves only once the user picks one; if they type their email and
  // submit instead, `abort()` cancels this request.
  async startConditional() {
    if (!window.PublicKeyCredential) return;
    if (!(await PublicKeyCredential.isConditionalMediationAvailable?.())) return;

    this.abortController = new AbortController();
    try {
      const assertion = await get({
        publicKey: this.optionsValue,
        mediation: "conditional",
        signal: this.abortController.signal,
      });
      this.submit(assertion);
    } catch (error) {
      if (error.name !== "AbortError") console.warn("Passkey login failed", error);
    }
  }

  abort() {
    this.abortController?.abort();
  }

  async register(event) {
    event.preventDefault();
    try {
      const attestation = await create({ publicKey: this.optionsValue });
      this.submit(attestation);
    } catch (error) {
      console.warn("Passkey registration failed", error);
    }
  }

  // The user is already signed in (the email code set the cookie); just refresh the host
  // page into its signed-in state. The turbo:before-visit listener closes the modal.
  skip(event) {
    event.preventDefault();
    Turbo.visit(window.location.href, { action: "replace" });
  }

  submit(credential) {
    this.credentialTarget.value = JSON.stringify(credential);
    this.formTarget.requestSubmit();
  }
}
