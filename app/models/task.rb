class Task < ActiveRecord::Base
  belongs_to :user
  has_many :notes, dependent: :destroy

  scope :daily, -> { where(category: 'daily') }
  scope :weekly, -> { where(category: 'weekly') }
  scope :yearly, -> { where(category: 'yearly') }
end
