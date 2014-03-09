class Evaluations::LorisController < EvaluationsController
  before_filter :authenticate_user!
  
  def show
    super
  end

  def new
    @LORIitems = Evaluations::Lori.getLoriItems
    super(Evaluations::Lori)
  end

  def edit
    super
  end

  def create
    super(Evaluations::Lori)
  end

  def update
    super
  end

  def destroy
    super
  end


  private

  def buildViewParamsBeforeRender
    @LORIitems = Evaluations::Lori.getLoriItems
    super
  end

end
