# encoding: utf-8

class Evaluations::Lori < Evaluation
  # this is for Evaluations with evMethod=LORI (type=LoriEvaluation)
  #Override methods here

  def init
    self.evmethod_id ||= Evmethod.find_by_name("LORI v1.5").id
    super
  end

  def self.getItems
    [
      {:name => "Content Quality",
         :description => "Veracity, accuracy, balanced presentation of ideas, and appropriate level of detail", 
         :type=> "integer"},
      {:name => "Learning Goal Alignment",
        :description => "Alignment among learning goals, activities, assessments, and learner characteristics",
        :type=> "integer"},
      {:name => "Feedback and Adaptation",
        :description => "Adaptive content or feedback driven by differential learner input or learner modeling",
        :type=> "integer"},
      {:name => "Motivation",
        :description => "Ability to motivate and interest an identified population of learners",
        :type=> "integer"},
      {:name => "Presentation Design",
        :description => "Design of visual and auditory information for enhanced learning and efficient mental processing",
        :type=> "integer"},
      {:name => "Interaction Usability",
        :description => "Ease of navigation, predictability of the user interface, and quality of the interface help features",
        :type=> "integer"},
      {:name => "Accessibility",
        :description => "Design of controls and presentation formats to accommodate disabled and mobile learners",
        :type=> "integer"},
      {:name => "Reusability",
        :description => "Ability to use in varying learning contexts and with learners from differing backgrounds",
        :type=> "integer"},
      {:name => "Standards Compliance",
        :description => "Adherence to international standards and specifications",
        :type=> "integer"}
    ]
  end


  #############
  # Representation Data
  #############

  def self.representationData(lo)
    representationData = Hash.new
    iScores = []

    evaluations = lo.evaluations.where(:evmethod_id => Evmethod.find_by_name("LORI v1.5").id)
    if evaluations.length == 0
      return nil
    end

    9.times do |i|
      validEvaluations = Evaluation.getValidEvaluationsForItem(evaluations,i+1)
      if validEvaluations.length == 0
        #Means that this item has not been evaluated in any evaluation
        #All evaluations had leave this item in blank
        iScores.push(nil)
      else
        iScore = ((validEvaluations.average("item"+(i+1).to_s).to_f - 1) * 5/2.to_f).round(2)
        iScores.push(iScore)
      end
    end

    representationData["iScores"] = iScores
    loScoreForAverage = lo.scores.find_by_metric_id(Metric.find_by_type("Metrics::LORIAM").id)
    if !loScoreForAverage.nil?
      representationData["averageScore"] = loScoreForAverage.value.round(2)
    end
    representationData["name"] = lo.name
    representationData["labels"] = getItems.map{|li| li[0]}   
    representationData
  end

  def self.representationDataForLos(los)
    representationData = Hash.new
    iScores = [nil,nil,nil,nil,nil,nil,nil,nil,nil]

    los.each do |lo|
      rpdLo = representationData(lo)
      if !rpdLo.nil?
        iScoresLo = rpdLo["iScores"]
        9.times do |i|
          if !iScoresLo[i].nil?
            if iScores[i].nil?
              iScores[i] = iScoresLo[i]
            else
              iScores[i] = iScores[i] + iScoresLo[i]
            end
          end
        end
      end
    end

    losL = los.length
    9.times do |i|
      if !iScores[i].nil?
        iScores[i] = (iScores[i]/losL).round(2)
      end
    end

    representationData["iScores"] = iScores
    representationData["averageScore"] = (representationData["iScores"].sum/representationData["iScores"].size.to_f).round(2)
    representationData["labels"] = getItems.map{|li| li[0]}
    representationData
  end

  def self.representationDataForComparingLos(los)
    representationData = Hash.new
    los.each do |lo|
      rpdLo = representationData(lo)
      if !rpdLo.nil? and !rpdLo["iScores"].nil? and !rpdLo["iScores"].include? nil
        representationData[lo.id] = rpdLo
      end
    end
    representationData["labels"] = getItems.map{|li| li[0]}
    representationData
  end

end