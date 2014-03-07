class Evaluations::LoriController < EvaluationsController
  before_filter :authenticate_user!
  
  def new
    @lo = Lo.find(params[:lo_id])
    authorize! :rshow, @lo

    moduleName = self.controller_name.camelcase[0..self.controller_name.camelcase.length-2]
    @evmethod = Evmethod.find_by_module(moduleName)

    if params[:assignment_id]
      @assignment = Assignment.find(params[:assignment_id])
    else
      #Inferred
      @assignment = @lo.assignments.where(:status=> "Pending", :user_id => current_user.id, :evmethod_id => @evmethod.id).first
    end
    authorize! :rshow, @assignment

    @evaluation = Evaluations::Lori.new
    authorize! :new, @evaluation

    Utils.update_return_to(session,request)

    #Reviewers go to Home after create new evaluation
    if !current_user.role?("Admin")
      session[:return_to] = Rails.application.routes.url_helpers.home_path
    end

    @LORIitems = getLoriItems
    respond_to do |format|
      format.html
      format.json { render json: @evaluation }
    end
  end

  def create
    @evaluation = Evaluations::Lori.new(params[:evaluations_lori])
    @evaluation.completed_at = Time.now
    authorize! :create, @evaluation

    respond_to do |format|
      if @evaluation.save
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'The evaluation was successfully submitted.' }
      else
        format.html { renderError("An error occurred and the evaluation could not be created. Check all the fields and try again.","new") }
      end
    end
  end

  def show
    @evaluation = Evaluation.find(params[:id])
    authorize! :show, @evaluation

    buildViewParamsBeforeRender
  end

  def edit
    @evaluation = Evaluation.find(params[:id])
    authorize! :edit, @evaluation

    Utils.update_sessions_paths(session, evaluations_path, nil)
    Utils.update_return_to(session,request)
    buildViewParamsBeforeRender
  end

  def update
    @evaluation = Evaluation.find(params[:id])
    authorize! :update, @evaluation

    respond_to do |format|
      if @evaluation.update_attributes(params[:evaluations_lori])
        format.html { redirect_to Utils.return_after_create_or_update(session), notice: 'The evaluation was successfully updated.' }
      else
        format.html { renderError("Evaluation cannot be updated. Wrong params.","new") }
      end
    end
  end

  def destroy
    @evaluation = Evaluation.find(params[:id])
    authorize! :destroy, @evaluation

    @evaluation.destroy

    respond_to do |format|
      format.html { redirect_to Utils.return_after_destroy_path(session) }
      format.json { head :no_content }
    end
  end


  private

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

  private

  def renderError(msg,action)
    buildViewParamsBeforeRender
    flash[:alert] = msg
    render action: action
  end

  def buildViewParamsBeforeRender
    @lo = @evaluation.lo
    authorize! :rshow, @lo
    @evmethod = @evaluation.evmethod
    @LORIitems = getLoriItems
  end


end
