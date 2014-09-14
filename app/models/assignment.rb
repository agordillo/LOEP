class Assignment < ActiveRecord::Base
  attr_accessible :author_id, :user_id, :lo_id, :evmethod_id, :completed_at, :deadline, :description, :status

  belongs_to :user
  belongs_to :lo
  belongs_to :evmethod
  has_many :evaluations #optional

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

  validates_inclusion_of :status, :in => ["Pending", "Completed", "Rejected"], :allow_nil => false, :message => ": Invalid status value"

  validate :evmethods_blank

  def evmethods_blank
    if self.evmethod_id.blank?
      errors.add(:evmethods, I18n.t("assignments.message.error.at_least_one_evmethod"))
    else
      true
    end
  end

  validate :duplicated_assignment

  def duplicated_assignment
    if self.id.nil?
      assignments = Assignment.where(:user_id => self.user.id, :lo_id => self.lo_id, :evmethod_id => self.evmethod.id)
      if assignments.length > 0
        errors.add(:duplicated_assignments, ": " + I18n.t("assignments.message.warning.duplicated"))
      else
        true
      end
    else
      #Updating an existing resource
      true
    end
  end

  before_save :add_suitability

#-------------------------------------------------------------------------------------

  def self.allc(params = {})
    Assignment.where("evmethod_id in (?)",LOEP::Application.config.evmethods.map{|evmethod| evmethod.id})
  end

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

  def readable_updated_at
    Utils.getReadableDate(self.updated_at)
  end

  def readable_completed_at
  	unless Utils.getReadableDate(self.completed_at).blank?
      Utils.getReadableDate(self.completed_at)
    else
      (I18n.t("assignments.status.uncompleted") + " <span class='status_in_completed_at'>(" + readable_status + ")</span>").html_safe
    end
  end

  def readable_status
    case self.status
      when "Pending"
        return ("<span class='glyphicon glyphicon-time'></span> " + I18n.t("assignments.status.pending")).html_safe;
      when "Completed"
        return ("<span class='glyphicon glyphicon-ok'></span> " + I18n.t("assignments.status.completed")).html_safe;
      when "Rejected"    
        return ("<span class='glyphicon glyphicon-remove'></span> " + I18n.t("assignments.status.rejected")).html_safe;
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

  def markAsComplete
    self.status = "Completed"
    self.completed_at = Time.now
  end


  private

  def add_suitability
    if self.suitability.nil?
      self.suitability = MatchingSystem.getMatchingScore(self.lo,self.user)
    end
  end

end
