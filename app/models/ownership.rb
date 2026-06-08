# == Schema Information
#
# Table name: ownerships
#
#  id            :string           not null, primary key
#  moments_count :integer          default(0), not null
#  position      :integer          not null
#  role          :integer          default("contributor"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  album_id      :string           not null
#  user_id       :string           not null
#
class Ownership < ApplicationRecord
  belongs_to :user
  belongs_to :album

  has_many :moments, foreign_key: :uploader_id, inverse_of: :uploader, dependent: :destroy
  has_many :comments, foreign_key: :author_id, inverse_of: :author, dependent: :destroy
  has_many :likes, dependent: :destroy

  enum :role, {contributor: 0, creator: 1}, default: :contributor

  # Per-album order (the palette slot): a user's index in this list maps to their color.
  positioned on: :album
  default_scope { order(:position) }

  validates :user_id, uniqueness: {scope: :album_id}
  validate :single_creator_per_album

  private

  def single_creator_per_album
    return unless creator?
    return unless album

    clashing = album.ownerships.where(role: :creator)
    clashing = clashing.where.not(id:) if persisted?
    errors.add(:role, "album already has a creator") if clashing.exists?
  end
end
