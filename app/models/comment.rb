# == Schema Information
#
# Table name: comments
#
#  id         :string           not null, primary key
#  body       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :string           not null
#  moment_id  :string           not null
#
class Comment < ApplicationRecord
  belongs_to :moment, counter_cache: true, inverse_of: :comments
  belongs_to :author, class_name: "Ownership", inverse_of: :comments

  validates :body, presence: true, length: {maximum: 5_000}
end
