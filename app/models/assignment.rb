class Assignment < ActiveRecord::Base
  attr_accessible :author_id, :user_id, :lo_id, :evmethod_id, :completed_at, :deadline, :description, :status

  belongs_to :user
  belongs_to :lo
  belongs_to :evmethod
  has_one :evaluation #optional

  validates :author_id,
  :presence => true

  validates :user_id,
  :presence => true

  validates :lo_id,
  :presence => true

  validates :evmethod_id,
  :presence => true

  validates :status,
  :presence => true

  validate :evmethods_blank

  def evmethods_blank
    if self.evmethod_id.blank?
      errors.add(:emethods, 'You should choose at least one evaluation method')
    else
      true
    end
  end

  before_save :add_suitability

#-------------------------------------------------------------------------------------

  def author
  	unless self.author_id.nil?
  		User.find(self.author_id)
  	end
  end

  def reviewer
    self.user
  end

  def readable_evmethod
    evmethod.name
  end

  def readable_deadline
  	Utils.getReadableDate(self.deadline)
  end

  def readable_completed_at
  	if !Utils.getReadableDate(self.completed_at).blank?
      Utils.getReadableDate(self.completed_at)
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

  def compareAssignmentForReviewers(assignment)
    if self.status=="Pending"
      if assignment.status != "Pending"
        return 1
      else
        return self.suitability <=> assignment.suitability
      end
    end

    if assignment.status=="Pending"
      return -1
    end

    #No pending assignments at this point

    if self.status=="Completed"
      if assignment.status != "Completed"
        return 1
      else
        return self.updated_at <=> assignment.updated_at
      end
    end

    if assignment.status=="Completed"
      return -1
    end

    return self.updated_at <=> assignment.updated_at
  end

  def compareAssignmentForAdmins(assignment)
    return self.updated_at <=> assignment.updated_at
  end


  private

  def add_suitability
    if self.suitability.nil?
      self.suitability = MatchingSystem.getMatchingScore(self.lo,self.user)
    end
  end

end
