class Entry < ApplicationRecord
  belongs_to :user
  validates :date, :body, presence: true
end