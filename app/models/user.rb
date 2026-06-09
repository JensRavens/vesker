# == Schema Information
#
# Table name: users
#
#  id         :string           not null, primary key
#  email      :string           not null
#  name       :string           not null
#  roles      :json             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  # Site-wide capabilities, stored in the `roles` array column (not album-scoped —
  # that's Ownership#role). A user is a site admin iff "admin" is in this array.
  ROLES = ["admin"].freeze

  has_many :ownerships, dependent: :destroy
  has_many :albums, through: :ownerships
  has_many :passkeys, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  before_validation :prefill_name_from_email

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :name, presence: true
  validate :roles_are_known

  def admin?
    roles.include?("admin")
  end

  private

  def roles_are_known
    errors.add(:roles, :inclusion) if (roles - ROLES).any?
  end

  # Default the name to a title-cased version of the email local-part when none is given,
  # treating ".", "_" and "-" as word separators (neo.m@… → "Neo M").
  def prefill_name_from_email
    self.name = email.split("@").first.gsub(/[._-]+/, " ").titleize if name.blank? && email.present?
  end
end
