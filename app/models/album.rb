# == Schema Information
#
# Table name: albums
#
#  id         :string           not null, primary key
#  slug       :string           not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Album < ApplicationRecord
  # The slug is a random, unguessable token — it IS the access control. Not name-derived
  # (the title may be blank at creation). Stable across renames.
  has_secure_token :slug

  has_many :ownerships, dependent: :destroy
  has_many :moments, dependent: :destroy
  has_many :users, through: :ownerships

  # A read-only view of the creator's ownership; the records are owned (and destroyed)
  # by `has_many :ownerships` above, so no separate :dependent here.
  has_one :creator_ownership, -> { where(role: :creator) }, # rubocop:disable Rails/HasManyOrHasOneDependent
    class_name: "Ownership", inverse_of: :album
  has_one :creator, through: :creator_ownership, source: :user

  def to_param
    slug
  end
end
