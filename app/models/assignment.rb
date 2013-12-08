class Assignment < ActiveRecord::Base
  attr_accessible :author_id, :completed_at, :deadline, :description, :emethods, :lo_id, :status, :user_id
end
