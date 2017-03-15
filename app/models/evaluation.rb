class Evaluation < ActiveRecord::Base
  attr_accessible :user_id, :assignment_id, :lo_id, :evmethod_id, :completed_at, :comments, :score, :external, :app_id, :id_user_app,
  :item1, :item2, :item3, :item4, :item5, :item6, :item7, :item8, :item9, :item10, :item11, :item12, :item13, :item14, :item15, :item16, :item17, :item18, :item19, :item20, :item21, :item22, :item23, :item24, :item25, :item26, :item27, :item28, :item29, :item30, :item31, :item32, :item33, :item34, :item35, :item36, :item37, :item38, :item39, :item40, :item41, :item42, :item43, :item44, :item45, :item46, :item47, :item48, :item49, :item50, :item51, :item52, :item53, :item54, :item55, :item56, :item57, :item58, :item59, :item60, :item61, :item62, :item63, :item64, :item65, :item66, :item67, :item68, :item69, :item70, :item71, :item72, :item73, :item74, :item75, :item76, :item77, :item78, :item79, :item80, :item81, :item82, :item83, :item84, :item85, :item86, :item87, :item88, :item89, :item90, :item91, :item92, :item93, :item94, :item95, :item96, :item97, :item98, :item99, 
  :titem1, :titem2, :titem3, :titem4, :titem5, :titem6, :titem7, :titem8, :titem9, :titem10, :titem11, :titem12, :titem13, :titem14, :titem15, :titem16, :titem17, :titem18, :titem19, :titem20, :titem21, :titem22, :titem23, :titem24, :titem25, :titem26, :titem27, :titem28, :titem29, :titem30, :titem31, :titem32, :titem33, :titem34, :titem35, :titem36, :titem37, :titem38, :titem39, :titem40,
  :sitem1, :sitem2, :sitem3, :sitem4, :sitem5,
  :uc_age, :uc_gender, :loc_context, :loc_grade, :loc_strategy

  belongs_to :user
  belongs_to :app
  belongs_to :lo
  belongs_to :evmethod
  belongs_to :assignment #optional

  validate :has_owner
  def has_owner
    return true if self.automatic? #Automatic evaluations do not require owners
    unless self.external
      return errors[:base] << "Evaluation without user" if user_id.blank?
    else
      return errors[:base] << "External evaluation without app" if self.app_id.blank?
    end
    true
  end
  validates :lo_id, :presence => true
  validates :evmethod_id, :presence => true
  validate :is_score_wrong
  def is_score_wrong
    return errors.add(:score, I18n.t("evaluations.message.error.overall_score")) if !self.score.nil? and !Utils.is_numeric?(self.score)
    true
  end
  validate :duplicated_evaluation
  def duplicated_evaluation
    #No check duplicated evaluations when:
    #!self.new_record?? => Updating an existing evaluation
    #!self.external and self.evmethod.allow_multiple_evaluations => EvMethod that allows multiple evaluations
    #self.external and self.anonymous? => External anonymous evaluations (without id_user_app)
    #!self.automatic? and !user.nil? and user.isAdmin? => The user is an Admin, and evmethod is manual
    return true if !self.new_record? or (!self.external and self.evmethod.allow_multiple_evaluations) or 
    (self.external and self.anonymous?) or (!self.automatic? and !user.nil? and user.isAdmin?)

    queryParams = {:lo_id => self.lo_id, :evmethod_id => self.evmethod.id}
    unless self.automatic?
      if !self.external
        queryParams[:user_id] = self.user.id
      elsif !self.id_user_app.nil?
        queryParams[:app_id] = self.app_id
        queryParams[:id_user_app] = self.id_user_app
      end
    end

    evaluations = Evaluation.where(queryParams)
    return errors[:base] << I18n.t("evaluations.message.error.duplicated") if evaluations.length > 0
    true
  end
  validates :uc_age, :numericality => { :greater_than => 0, :less_than_or_equal_to => 100 }, :allow_blank => true
  validates :uc_gender, :numericality => { :greater_than => 0, :less_than_or_equal_to => 2 }, :allow_blank => true
  validates_inclusion_of :loc_context, :in => I18n.t("context.lo.context_select", :locale => :en).map{|k,v| k.to_s}, :allow_nil => true, :message => ": " + I18n.t("dictionary.invalid")
  validates_inclusion_of :loc_strategy, :in => I18n.t("context.lo.strategy_select", :locale => :en).map{|k,v| k.to_s}, :allow_nil => true, :message => ": " + I18n.t("dictionary.invalid")


  after_initialize :init
  before_validation :checkScoreBeforeSave
  after_create :checkAssignment
  after_save :updateScores
  after_save :checkCallbacks
  after_destroy :updateScores


  ################################
  # Method to inherit and override
  ################################

  def init
  end

  def getItems
    self.class.getItems
  end

  def self.getItems
    []
  end

  def getScale
    self.class.getScale
  end

  def self.getScale
    # Default scale. Override.
    return [0,10]
  end

  def getFormOptions
    self.class.getFormOptions
  end

  def self.getFormOptions
    {}
  end

  ################################
  # Constants
  ################################

  def self.ALL_ITEM_TYPES
    ["integer","decimal","string","text"]
  end

  def self.ALL_ITEM_FIELDS
    self.ALL_ITEM_TYPES.map{|itemType| fieldNameForItemType(itemType)}
  end

  def self.fieldNameForItemType(itemType)
    case itemType
    when "integer"
      "item"
    when "decimal"
      "ditem"
    when "string"
      "sitem"
    when "text"
      "titem"
    else
      nil
    end
  end

  def self.ALL_COMMON_FIELDS
    ["comments","score"]
  end

  #######################
  # Get extended Evaluation Data
  #######################

  def extended_attributes
    evModule = self.evmethod.module.constantize
    itemFieldPrefixNames = evModule.ALL_ITEM_FIELDS
    itemKeys = evModule.getItemsArray
    attrs = self.attributes.reject{ |key,value| key.start_with?(*itemFieldPrefixNames) and !itemKeys.include?(key)}

    attrs["Reviewer"] = (self.user.nil? ? "Automatic" : self.user.name)
    attrs["loName"] = self.lo.name
    attrs["evMethodName"] = self.evmethod.name

    attrs["created_at"] = Utils.getReadableDate(attrs["created_at"])
    attrs["updated_at"] = Utils.getReadableDate(attrs["updated_at"])
    attrs["completed_at"] = Utils.getReadableDate(attrs["completed_at"])

    commonKeys = attrs.reject{ |key,value| (key.start_with?(*(itemFieldPrefixNames + ["comments","score"])))}.keys
    sortedKeys = attrs.keys.sort{ |k1,k2|
      iK1 = commonKeys.include? k1
      iK2 = commonKeys.include? k2
      if iK1
        if iK2
          0
        else
          -1
        end
      else
        if iK2
          1
        else
          iiK1 = k1.start_with?(*itemFieldPrefixNames)
          iiK2 = k2.start_with?(*itemFieldPrefixNames)
          if iiK1
            if iiK2
              if k1.match(/[a-z]+/).values_at(0).first == k2.match(/[a-z]+/).values_at(0).first
                k1.match(/\d+/).values_at(0).first.to_i <=> k2.match(/\d+/).values_at(0).first.to_i
              else
                k1.casecmp(k2)
              end
            else
              -1
            end
          else
            if iiK2
              1
            else
              k1.casecmp(k2)
            end
          end
        end
      end
    }

    new_attrs = Hash.new
    sortedKeys.each do |key|
      new_attrs[key] = attrs[key]
    end

    Metric.allc.select { |m| m.evmethods == [self.evmethod] }.each do |m|
      #Metrics that only use this ev method.
      #In this case, the scores of the metrics can be included in the evaluations
      new_attrs[m.name] = m.getScoreForEvaluation(self)
    end
    
    new_attrs
  end

  def xlsx_attributes
    attrs = self.extended_attributes
    attrs
  end

  def items_attributes(itemTypes=nil)
    itemsArray = self.getItemsArray(itemTypes)
    itemsArray = (itemsArray + self.class.ALL_COMMON_FIELDS).uniq if !itemTypes.blank? and itemTypes.include?("common")
    self.attributes.select{ |key,value| itemsArray.include?(key) }
  end


  #Path Methods

  def evaluation_path
    evaluationModule = self.evmethod.getEvaluationModule
    helper_method_name = self.evmethod.module.gsub(":","").underscore + "_path"
    evaluation_path = Rails.application.routes.url_helpers.send(helper_method_name,self)
  end

  def edit_evaluation_path
    evaluationModule = self.evmethod.getEvaluationModule
    helper_method_name = "edit_" + self.evmethod.module.gsub(":","").underscore + "_path"
    evaluation_path = Rails.application.routes.url_helpers.send(helper_method_name,self)
  end

  ###########
  # Utils
  ###########

  def self.allc(params = {})
    if params[:automatic] === false
      evmethods_ids =  LOEP::Application.config.evmethods_human_ids 
    else
      evmethods_ids = LOEP::Application.config.evmethods_ids
    end
    Evaluation.where("evmethod_id in (?)", evmethods_ids)
  end

  def self.automatic
    Evaluation.joins(:evmethod).where("evmethods.automatic = true")
  end

  def self.human
    Evaluation.joins(:evmethod).where("evmethods.automatic = false")
  end

  def self.external
    Evaluation.where("external = true")
  end

  def self.internal
    Evaluation.where("external = false")
  end

  #Get the real reviewer of the Evaluation
  def readable_reviewer
    if self.external
      ((self.anonymous? ? I18n.t("dictionary.anonymous") : "#" + self.id_user_app[0..6]) + ' (<a href="'+Rails.application.routes.url_helpers.app_path(self.app)+'">'+self.app.name+'</a>)').html_safe
    elsif !self.user.nil?
      ('<a href="'+Rails.application.routes.url_helpers.user_path(self.user)+'">'+self.user.name+'</a>').html_safe
    elsif self.automatic?
      "Automatic"
    end
  end
  
  def readable_completed_at
    Utils.getReadableDate(self.completed_at)
  end

  def self.getValidEvaluationsForItem(evaluations,itemName)
    itemName = [itemName] unless itemName.is_a? Array
    getValidEvaluationsForItems(evaluations,itemName)
  end

  def self.getValidEvaluationsForItems(evaluations,itemNames)
    # Evaluation.where(:lo_id => Lo.first.id).where('item1!=-1 and item2 !=-1 and item3!=-1 and item17 IS NOT NULL')
    # Usage example: Evaluation.getValidEvaluationsForItems(Evaluation,["item1","item2","item3","ditem1"])
    query = "";
    itemNames.each_with_index do |itemName,index|
      query = query + " and " if (index!=0)
      if itemName=="comments" or itemName.start_with?("titem") or itemName.start_with?("sitem")
        query = query + (itemName.to_s) + ' is NOT NULL and RTRIM(' + (itemName.to_s) + ') !=""'
      else
        query = query + (itemName.to_s) + ' != -1'
      end
    end
    evaluations = Evaluation.where("id in (?)",evaluations.map{|ev| ev.id}) if evaluations.is_a? Array
    evaluations.where(query)
  end

  def getItemsArray(itemTypes=nil)
    self.class.getItemsArray(itemTypes)
  end

  def self.getItemsArray(itemTypes=nil)
    itemNames = []
    itemTypes = processItemTypesArray(itemTypes)

    itemTypesIndex = Hash.new
    itemTypes.each do |itemType|
      itemTypesIndex[itemType] = 1
    end

    getItemsWithType(itemTypes).each do |item|
      itemFieldName = fieldNameForItemType(item[:type])
      itemNames.push(itemFieldName + (itemTypesIndex[item[:type]]).to_s) if itemFieldName.is_a? String
      itemTypesIndex[item[:type]] += 1
    end

    itemNames
  end

  def self.getItemsWithType(types=nil,items=nil)
    types = processItemTypesArray(types)
    items = getItems if items.nil?
    items.reject{|item| item[:type].nil? or !types.include? item[:type]}
  end

  def self.processItemTypesArray(itemTypes)
    itemTypes = self.ALL_ITEM_TYPES if itemTypes.blank?
    itemTypes = [itemTypes] unless itemTypes.is_a? Array
    if itemTypes.include?("numeric")
      itemTypes.delete("numeric")
      itemTypes += ["integer","decimal"]
    end
    if itemTypes.include?("textual")
      itemTypes.delete("textual")
      itemTypes += ["string","text"]
    end
    itemTypes.uniq
  end

  def automatic?
    self.evmethod.automatic
  end

  def anonymous?
    self.external and self.id_user_app.blank?
  end


  ################################
  # Method for evaluations to inherit
  ################################

  def getEvaluationData
    evData = Hash.new
    evmethodName = self.evmethod.name
    evmethodModule = self.evmethod.getEvaluationModule
    evData[evmethodName] = Hash.new
    evData[evmethodName][:evaluations] = [self]
    evData[evmethodName][:items] = [] #Value of numeric items
    evData[evmethodName][:titems] = {} #Hash with array of values of textual items
    evData[evmethodName][:comments] = [] #Array with comments

    #Numeric Items
    evMethodItems = evmethodModule.getItemsArray("numeric")
    validEvaluations = Evaluation.getValidEvaluationsForItem([self],evMethodItems)

    if validEvaluations.length === 0
      evMethodItems.each do |itemName|
        evData[evmethodName][:items].push(nil)
      end
    else
      evMethodItems.each do |itemName|
        iScore = validEvaluations.average(itemName).to_f
        evData[evmethod.name][:items].push(iScore)
      end
    end

    #Textual Items
    evMethodItemsTitems = evmethodModule.getItemsArray("textual")
    evMethodItemsTitems.each do |itemName|
      validEvaluations = Evaluation.getValidEvaluationsForItem([self],itemName)
      if validEvaluations.blank?
        evData[evmethodName][:titems][itemName] = []
      else
        evData[evmethodName][:titems][itemName] = validEvaluations.map{|e| e.send(itemName)}
      end
    end

    #Comments
    evaluationsWithComments = Evaluation.getValidEvaluationsForItem([self],"comments")
    evData[evmethodName][:comments] = evaluationsWithComments.map{|e| e.comments} unless evaluationsWithComments.blank?

    evData
  end

  #Data for representing one single LO
  def self.representationData(lo,metric=nil)
    representationData = Evmethod.find_by_module(self.name).buildRepresentationData(lo,metric)
  end

  #Data for representing aggregated stats of a LO group
  def self.representationDataForLos(los)
    Evmethod.find_by_module(self.name).representationDataForLos(los)
  end

  #Data for comparing a LO group among them
  def self.representationDataForComparingLos(los)
    Evmethod.find_by_module(self.name).representationDataForComparingLos(los)
  end

  #Create automatic evaluations (only for automatic evaluation models)
  def self.createAutomaticEvaluation(lo)
    evaluation = self.where(:lo_id => lo.id).first
    if evaluation.nil?
      evaluation = self.new
      evaluation.lo_id = lo.id
      evaluation.completed_at = Time.now
    end
    evaluation
  end


  private

  #Prevent wrong scores to be saved
  def checkScoreBeforeSave
    self.score = [[0,self.score].max,10].min if !self.score.nil? and Utils.is_numeric?(self.score)
  end

  def checkAssignment
    return if self.automatic? or self.external

    # Look for the related assignment of this evaluation
    # It should be a pending assignment of the user with the same Lo and the same evaluation model
    assignment = self.user.assignments.where(:status => "Pending", :lo_id=>self.lo.id, :evmethod_id=>self.evmethod.id).first

    unless assignment.nil?
      #Add the evaluation to the assignment, if its not included
      assignment.evaluations.push(self) if self.assignment_id.nil? and !assignment.evaluations.include? self
      assignment.markAsComplete unless self.evmethod.allow_multiple_evaluations
      assignment.save!
    end
  end

  def updateScores
    # Look for scores than should be updated or created after create or remove this evaluation

    #1. Get EvMethod of the Evaluation
    #2. Get all the Metrics that used this EvMethod
    #3. For each Metric, create/update the scores of the LO.
    metrics = Metric.allc.select { |m| m.evmethods.include? self.evmethod }
    metrics.each do |m|
      s = self.lo.scores.where(:metric_id=>m.id).first
      unless s.nil?
        #Update Score
        loScore = s.metric.getScoreForLo(s.lo)
        if loScore.nil?
          s.destroy
        else
          #Update score
          s.value = loScore
          s.save!
        end
      else
        #Create score
        s = Score.new
        s.metric_id = m.id
        s.lo_id = self.lo.id
        s.save #If the value can't be calculated, the score will not be saved. (Don't use save!)
      end
    end
  end

  def checkCallbacks
    #Look for any web app that want to be notified about this evaluation
    if !self.lo.app.nil? and !self.lo.app.callback.nil?
      #An App wants to be notified that there is new data about this Lo
      LoepNotifier.notifyLoUpdate(self.lo.app,self.lo)
    end
  end
  
end
