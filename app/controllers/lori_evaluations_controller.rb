class LoriEvaluationsController < ApplicationController

  def new
    @lo = Lo.find(params[:lo_id])
    authorize! :rshow, @lo

    moduleName = self.controller_name.camelcase[0..self.controller_name.camelcase.length-2]
    @evmethod = Evmethod.find_by_module(moduleName)

    if params[:assignment_id]
      @assignment = Assignment.find(params[:assignment_id])
    else
      #Inferred
      @assignment = (@lo.assignments.where(:user_id => current_user.id).reject { |as| !as.evmethods.include? @evmethod }).first
    end
    authorize! :rshow, @assignment

    @evaluation = LoriEvaluation.new
    @LORIitems = getLoriItems
    respond_to do |format|
      format.html
      format.json { render json: @evaluation }
    end
  end

  def create
    @evaluation = LoriEvaluation.new(params[:lori_evaluation])
    @evaluation.completed_at = Time.now
    respond_to do |format|
      if @evaluation.save
        format.html { redirect_to home_path, notice: 'Evaluation was successfully submitted.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def getLoriItems
    [
      ["Content Quality","Veracity, accuracy, balanced presentation of ideas, and appropriate level of detail"],
      ["Learning Goal Alignment","Alignment among learning goals, activities, assessments, and learner characteristics"],
      ["Feedback and Adaptation","Adaptive content or feedback driven by differential learner input or learner modeling"],
      ["Motivation","Ability to motivate and interest an identified population of learners"],
      ["Presentation Design","Design of visual and auditory information for enhanced learning and efficient mental processing"],
      ["Interaction Usability","Ease of navigation, predictability of the user interface, and quality of the interface help features"],
      ["Accessibility","Design of controls and presentation formats to accommodate disabled and mobile learners"],
      ["Reusability","Ability to use in varying learning contexts and with learners from differing backgrounds"],
      ["Standards Compliance","Adherence to international standards and specifications"]
    ]
  end

end
