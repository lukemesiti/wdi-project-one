class Note < ActiveRecord::Base
  belongs_to :task

  validates :name, :task_id, presence: true
end
