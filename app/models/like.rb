# == Schema Information
#
# Table name: likes
#
#  id           :string           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  moment_id    :string           not null
#  ownership_id :string           not null
#
class Like < ApplicationRecord
  belongs_to :moment, counter_cache: true, inverse_of: :likes
  belongs_to :ownership

  validates :ownership_id, uniqueness: {scope: :moment_id}
end
