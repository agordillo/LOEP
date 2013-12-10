class Assignment < ActiveRecord::Base
  attr_accessible :author_id, :completed_at, :deadline, :description, :emethods, :lo_id, :status, :user_id

  belongs_to :user
  belongs_to :lo

  def author
  	unless self.author_id.nil?
  		User.find(self.author_id)
  	end
  end

  def getEMethods
  	unless self.emethods.nil?
  		begin
  			JSON(self.emethods)
  		rescue
  			[]
  		end
  	end
  end

  def readable_deadline
  	readable_date(self.deadline)
  end

  def readable_completed_at
  	readable_date(self.completed_at)
  end

  private

  def readable_date(date)
    unless date.nil?
      date.strftime("%d/%m/%Y %H:%M %P")
      #For Ruby < 1.9
      # date.strftime("%d/%m/%Y %H:%M %p").sub(' AM', ' am').sub(' PM', ' pm')
    else
      ""
    end
  end

end
