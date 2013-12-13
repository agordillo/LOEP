class Evaluation < ActiveRecord::Base
  attr_accessible :user_id, :assignment_id, :lo_id, :evmethod_id, :completed_at, :comments,
  :item1, :item2, :item3, :item4, :item5, :item6, :item7, :item8, :item9, :item10, :item11, :item12, :item13, :item14, :item15, :item16, :item17, :item18, :item19, :item20, :item21, :item22, :item23, :item24, :item25,
  :titem1, :titem2, :titem3, :titem4, :titem5, :titem6, :titem7, :titem8, :titem9, :titem10,
  :sitem1, :sitem2, :sitem3, :sitem4, :sitem5

  belongs_to :user
  belongs_to :lo
  belongs_to :evmethod
  belongs_to :assignment #optional

  validates :user_id,
  :presence => true

  validates :lo_id,
  :presence => true

  validates :evmethod_id,
  :presence => true

  after_save :update_assignments


  def readable_completed_at
    readable_date(self.completed_at)
  end


  #Path Methods

  def evaluation_path
    evaluationModule = self.evmethod.getEvaluationModule
    helper_method_name = self.evmethod.module.underscore + "_path"
    evaluation_path = Rails.application.routes.url_helpers.send(helper_method_name,self)
  end

  def edit_evaluation_path
    evaluationModule = self.evmethod.getEvaluationModule
    helper_method_name = "edit_" + self.evmethod.module.underscore + "_path"
    evaluation_path = Rails.application.routes.url_helpers.send(helper_method_name,self)
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

  def update_assignments
    # Look assignments that can be considered completed after this evaluation
    # Pending assignments of the user, with the same Lo and the same evaluation method
    candidate_assignments = self.user.assignments.where(:status => "Pending", :lo_id=>self.lo.id).reject{ |as| !as.evmethods.include? Evmethod.find(self.evmethod.id) }
    candidate_assignments.each do |as|
      #Add the evaluation to the assignment, if its not included
      if !as.evaluations.include? self
        as.evaluations.push(self)
      end
      check_assignment_status(as)
    end
  end

  def check_assignment_status(assignment)
      assignment.evmethods.each do |evmethod|
        if !check_evmethod(assignment,evmethod)
          return
        end
      end
      #All evmethods completed
      assignment.status = "Completed"
      assignment.save
  end

  #Determine if this assignment has been completed with the following evmethod
  def check_evmethod(assignment,evmethod)
    !assignment.evaluations.where(:evmethod_id => evmethod.id).blank?
  end
  
end
