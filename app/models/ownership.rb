# == Schema Information
#
# Table name: ownerships
#
#  id            :string           not null, primary key
#  color         :integer          not null
#  moments_count :integer          default(0), not null
#  role          :integer          default("contributor"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  album_id      :string           not null
#  user_id       :string           not null
#
class Ownership < ApplicationRecord
  include Palette

  belongs_to :user
  belongs_to :album

  has_many :moments, foreign_key: :uploader_id, inverse_of: :uploader, dependent: :destroy
  has_many :comments, foreign_key: :author_id, inverse_of: :author, dependent: :destroy
  has_many :likes, dependent: :destroy

  enum :role, {contributor: 0, admin: 1, creator: 2}, default: :contributor

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
