class Assignment < ActiveRecord::Base
  attr_accessible :author_id, :completed_at, :deadline, :description, :lo_id, :status, :user_id, :evmethods

  belongs_to :user
  belongs_to :lo
  has_and_belongs_to_many :evmethods
  has_many :evaluations

  validates :author_id,
  :presence => true

  validates :user_id,
  :presence => true

  validates :lo_id,
  :presence => true

  validates :status,
  :presence => true

  validate :evmethods_blank

  def evmethods_blank
    if self.evmethods.blank?
      errors.add(:emethods, 'You should choose at least one evaluation method')
    else
      true
    end
  end

#-------------------------------------------------------------------------------------

  def author
  	unless self.author_id.nil?
  		User.find(self.author_id)
  	end
  end

  def getEvMethods
  	unless self.evmethods.empty?
  		self.evmethods.map { |evmethod| evmethod.id }
  	end
  end

  def readable_evmethods
    unless self.evmethods.empty?
      self.evmethods.map { |evmethod| evmethod.name }.join(",")
    end
  end

  def readable_deadline
  	readable_date(self.deadline)
  end

  def readable_completed_at
  	if !readable_date(self.completed_at).blank?
      readable_date(self.completed_at)
    else
      ("Uncompleted <span class='status_in_completed_at'>(" + readable_status + ")</span>").html_safe
    end
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
