class Task < ActiveRecord::Base
  belongs_to :user
  has_many :notes, dependent: :destroy

  scope :previous_daily, -> { where(category: 'daily').where("created_at <= ?", Time.zone.now.beginning_of_day) }
  scope :previous_weekly, -> { where(category: 'weekly').where("created_at <= ?", Time.zone.now.beginning_of_week) }
  scope :previous_yearly, -> { where(category: 'yearly').where("created_at <= ?", Time.zone.now.beginning_of_year) }
  
  scope :current_daily, -> { where(category: 'daily').where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
  scope :current_weekly, -> { where(category: 'weekly').where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week) }
  scope :current_yearly, -> { where(category: 'yearly').where(created_at: Time.zone.now.beginning_of_year..Time.zone.now.end_of_year) }
end
