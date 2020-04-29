class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  #外部キーが user_id 一つでは無いから、このように定義する必要あり。
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
