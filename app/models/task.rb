class Task < ActiveRecord::Base
  belongs_to :user
  has_many :notes, dependent: :destroy

  validates :name, :category, :user_id, presence: true
  validates :category, inclusion: { in: %w(daily weekly yearly), message: "%{value} is not a valid category" }

  scope :previous_daily, -> { where(category: CATEGORIES[0]).where("created_at <= ?", Time.now.beginning_of_day) }
  scope :previous_weekly, -> { where(category: CATEGORIES[1]).where("created_at <= ?", Time.now.beginning_of_week) }
  scope :previous_yearly, -> { where(category: CATEGORIES[2]).where("created_at <= ?", Time.now.beginning_of_year) }

  scope :daily, -> { where(category: CATEGORIES[0]).where(created_at: Time.now.beginning_of_day..Time.now.end_of_day) }
  scope :weekly, -> { where(category: CATEGORIES[1]).where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :yearly, -> { where(category: CATEGORIES[2]).where(created_at: Time.now.beginning_of_year..Time.now.end_of_year) }

  CATEGORIES = ['daily', 'weekly', 'yearly']
end
