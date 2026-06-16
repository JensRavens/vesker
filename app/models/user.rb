# == Schema Information
#
# Table name: users
#
#  id         :string           not null, primary key
#  admin      :boolean          default(FALSE), not null
#  email      :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  has_many :moments, foreign_key: :uploader_id, inverse_of: :uploader, dependent: :destroy
  has_many :comments, foreign_key: :author_id, inverse_of: :author, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :passkeys, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  before_validation :prefill_name_from_email

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :name, presence: true

  private

  # Default the name to a title-cased version of the email local-part when none is given,
  # treating ".", "_" and "-" as word separators (neo.m@… → "Neo M").
  def prefill_name_from_email
    self.name = email.split("@").first.gsub(/[._-]+/, " ").titleize if name.blank? && email.present?
  end
end
