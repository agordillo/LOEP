class Assignment < ActiveRecord::Base
  attr_accessible :author_id, :completed_at, :deadline, :description, :emethods, :lo_id, :status, :user_id

  belongs_to :user
  belongs_to :lo

  validates :author_id,
  :presence => true

  validates :user_id,
  :presence => true

  validates :lo_id,
  :presence => true

  validates :emethods,
  :presence => true

  validates :status,
  :presence => true

  validate :emethods_blank

  def emethods_blank
    begin
      if self.emethods.blank? || JSON(self.emethods).empty?
        raise 'You should choose at least one evaluation method'
      end
    rescue
      errors.add(:emethods, 'You should choose at least one evaluation method')
    end
  end

#-------------------------------------------------------------------------------------

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

  def readable_status
    case self.status
      when "Pending"
        return "<span class='glyphicon glyphicon-time'></span> Pending".html_safe;
      when "Completed"
        return "<span class='glyphicon glyphicon-ok'></span> Completed".html_safe;
      when "Rejected"    
        return "<span class='glyphicon glyphicon-remove'></span> Rejected".html_safe;
      else
        return "";
      end
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
