# encoding: utf-8

class Evaluations::Une71362Student < Evaluation
  # this is for Evaluations with evMethod=UNE 71362 - Student (type=Une71362StudentEvaluation)
  
  before_validation :saveCriteriaScores

  def init
    self.evmethod_id ||= Evmethod.find_by_name("UNE 71362 - Student").id
    super
  end

  def self.getItems
    items = []
    51.times do |i|
      item = {
        :name => I18n.t("evmethods.une71362_student.item" + (i+1).to_s + ".name"),
        :shortname => (i+1).to_s,
        :type=> "integer"
      }
      description = I18n.t("evmethods.une71362_student.item" + (i+1).to_s + ".description", default: "")
      item[:description] = description unless description.blank?
      items << item
    end
    2.times do |i|
      items << {
        :name => I18n.t("evmethods.une71362_student.item" + (i+52).to_s + ".name"),
        :type=> "text"
      }
    end
    items
  end

  def self.getScale
    return [0,10]
  end

  def self.getFormOptions
    {
      :scaleLegend => {
        :min => 0, 
        :max => 10
      },
      :explicitSkipAnswer => {
        :title => I18n.t("forms.evmethod.na")
      }
    }
  end

  def self.getSections
    [6,3,4,2,5,5,6,2,3,4,3,3,4,1,2]
  end

  def saveCriteriaScores
    firstSectionItem = 0
    lastSectionItem = 0

    self.class.getSections.each_with_index do |length,i|
      firstSectionItem = lastSectionItem+1
      lastSectionItem = firstSectionItem+length-1

      sectionScore = 0
      applicableItems = 0
      length.times do |i|
        itemScore = self.send("item#{firstSectionItem+i}")
        if !itemScore.nil? and itemScore!=-1
          applicableItems += 1
          sectionScore += itemScore
        end
      end

      if applicableItems > 0
        sectionScore = sectionScore/applicableItems.to_f
      else
        sectionScore = -1
      end

      self.send("ditem#{i+1}=", sectionScore)
    end
  end

  def self.hasEvaluatedLo(lo)
    #By default, LOEP consider that a LO has been evaluated with a evmethod, if for each numeric item of the method, exists at least one evaluation that rate it with a valid score.
    #For the UNE 71362 Student Profile evaluation method, LOEP will consider that a LO has been evaluated if, for each section, there is at least one evaluation that rate one of its items with a valid score.
    evmethod = Evmethod.find_by_module(self.name)
    evMethodEvaluations = lo.evaluations.where(:evmethod_id => evmethod.id)
    sections = self.getSections

    #Optimization
    return true unless Evaluation.getValidEvaluationsForItems(evMethodEvaluations,self.getItemsArray("numeric")).empty?

    firstSectionItem = 0
    lastSectionItem = 0
    nSections = sections.length
    sections.each_with_index do |length,i|
      break if i == nSections-1
      begin
        firstSectionItem = lastSectionItem+1
        lastSectionItem = firstSectionItem+length-1
        length.times do |i|
          raise "Break inner loop" unless Evaluation.getValidEvaluationsForItem(evMethodEvaluations,"item#{firstSectionItem+i}").empty?
          return false if i==length-1
        end
      rescue
        next
      end
    end
    return true
  end

  def self.representationData(lo,metric=nil)
    evmethod = Evmethod.find_by_module(self.name)
    evData = lo.getEvaluationData(evmethod)[evmethod.name]

    iScores = evData[:items]
    return nil if iScores.blank?

    #There is no need to scale scores since UNE scale is [0,10]

    #Calculate section scores
    sectionScores = []
    labels = []
    firstSectionItem = 0
    lastSectionItem = 0
    nSections = self.getSections.length
    self.getSections.unshift.each_with_index do |length,i|
      break if i == nSections-1
      firstSectionItem = lastSectionItem+1
      lastSectionItem = firstSectionItem+length-1

      sectionScore = 0
      applicableItems = 0
      length.times do |i|
        itemScore = iScores[firstSectionItem+i-1]
        if !itemScore.nil? and itemScore!=-1
          applicableItems += 1
          sectionScore += itemScore
        end
      end

      if applicableItems > 0
        sectionScore = (sectionScore/applicableItems.to_f).round(2)
      else
        sectionScore = nil
      end

      sectionScores.push(sectionScore)

      labels.push(I18n.t("evmethods.une71362_student.section" + (i+1).to_s + ".name"))
    end
    
    return nil if sectionScores.blank? or sectionScores.include? nil

    representationData = Hash.new
    representationData["iScores"] = sectionScores

    metric = Metric.allc.select{|m| m.evmethods == [evmethod]}.first if metric.nil?
    unless metric.nil?
      loScoreForAverage = lo.scores.find_by_metric_id(metric.id)
      representationData["averageScore"] = loScoreForAverage.value.round(2) unless loScoreForAverage.nil?
    end

    representationData["name"] = lo.name
    representationData["labels"] = labels
    representationData["engine"] = "Rgraph"
    representationData
  end

end