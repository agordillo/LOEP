# encoding: utf-8

#Metadata Quality Metric: Conformance

class Metrics::LomMetadataConformance < Metrics::LomMetadataItem

  def self.getScoreForMetadata(metadataJSON,options={})
    score = 0
    fieldWeights = Metrics::LomMetadataConformance.fieldWeights
    conformanceItems = Metrics::LomMetadataConformance.conformanceItems
    metadataFields = Metadata::Lom.metadata_fields_from_json(metadataJSON) rescue {}
    unless metadataFields.blank?
      metadataFields.each do |key, value|
        unless value.blank? or conformanceItems[key].blank?
          score += getScoreForMetadataField(key,value,options,conformanceItems) * fieldWeights[key]
        end
      end
    end
    score *= 10
    return score
  end

  def self.getScoreForMetadataField(key,value,options={},conformanceItems)
    score = 0
    case conformanceItems[key][:type]
    when "freetext"
      score = getScoreForFreeTextMetadataField(key,value,options,conformanceItems)
    when "categorical"
      score = getScoreForCategoricalMetadataField(key,value,options,conformanceItems)
    end
    [0,[score,1].min].max
  end

  def self.getScoreForFreeTextMetadataField(key,value,options={},conformanceItems)
    score = FreeTextTFIDF(value,options.merge({:key => key}))

    unless score==0
      score = Math.log(score)

      #Store max instance (uncomment to calculate maximums)
      # maxiumValue = MetadataField.updateMax(key,score,options)

      #Normalize score
      maxiumValue = conformanceItems[key][:max]

      score = [0,[score/(maxiumValue.to_f),1].min].max
    end

    score
  end

  def self.getScoreForCategoricalMetadataField(key,value,options={},conformanceItems={})
    score = 0

    query = {:name => key, :field_type => "categorical", :repository => options[:repository]}
    allGroupedMetadataInstances = GroupedMetadataField.where(query)

    n = [1,allGroupedMetadataInstances.find_by_value(nil).n].max rescue 1
    times = [1,allGroupedMetadataInstances.find_by_value(value.downcase).n].max rescue 1

    unless n == 1
      score = (1 - (Math.log(times)/Math.log(n))) rescue 0
    else
      score = 1 if times>0 # n=1 and times€{0,1}
    end

    score
  end

  def self.processFreeText(text,options={})
    return {} unless text.is_a? String
    options = {:separator => " "}.merge(options)
    text = text.gsub(/([\n])/," ").gsub(/[^0-9a-záéíóúñçÁÉÍÓÚÑÇº|\s]/i,"").downcase
    words = Hash.new
    text.split(options[:separator]).each do |word|
      words[word] = 0 if words[word].nil?
      words[word] += 1
    end
    words
  end

  def self.TFIDF(word,text,options)
    if options[:occurrences].is_a? Numeric
      occurrencesOfWordInText = options[:occurrences]
    else
      occurrencesOfWordInText = Metrics::LomMetadataConformance.processFreeText(text)[word] || 0
    end
    textWordFrequency = occurrencesOfWordInText
    return 0 if textWordFrequency==0
    
    query = {:field_type => "freetext", :repository => options[:repository]}
    unless options[:key].blank?
      query = query.merge({:name => options[:key]})
    end
    
    allGroupedMetadataInstances = GroupedMetadataField.where(query)
    allResourcesInRepository = [1,allGroupedMetadataInstances.find_by_value(nil).n].max rescue 1
    occurrencesOfWordInRepository = [1,allGroupedMetadataInstances.find_by_value(word.downcase).n].max rescue 1

    # This code do the same (than the previous lines) but it is slower. We use the GroupedMetadataField to make things fast.
    # allMetadataInstances = MetadataField.where(query)
    # allResourcesInRepository = [1,allMetadataInstances.group(:metadata_id).length].max
    # occurrencesOfWordInRepository = [1,allMetadataInstances.where(:value => word.downcase).group(:metadata_id).length].max

    repositoryWordFrequency = (occurrencesOfWordInRepository.to_f / allResourcesInRepository)
    textWordFrequency * Math.log(1/repositoryWordFrequency) rescue 0
  end

  def self.FreeTextTFIDF(freeText,options)
    freeTextTFIDF = 0
    processFreeText(freeText).each do |word,occurrences|
      freeTextTFIDF += TFIDF(word,freeText,options.merge({:occurrences => occurrences}))
    end
    freeTextTFIDF
  end

  def self.conformanceItems
    cItems = Hash.new
    cItems["1.1.2"] = {type: "freetext", max: 1.5}
    cItems["1.2"] = {type: "freetext", max: 3.25}
    cItems["1.3"] = {type: "categorical"}
    cItems["1.4"] = {type: "freetext", max: 5.5}
    cItems["1.5"] = {type: "freetext", max: 4.25}
    cItems
  end

  def self.fieldWeights
    fieldWeights = {}

    fieldWeights["1.1.1"] = BigDecimal(0,6)
    fieldWeights["1.1.2"] = BigDecimal(0.2,6)
    fieldWeights["1.2"] = BigDecimal(0.25,6)
    fieldWeights["1.3"] = BigDecimal(0.15,6)
    fieldWeights["1.4"] = BigDecimal(0.2,6)
    fieldWeights["1.5"] = BigDecimal(0.2,6)
    fieldWeights["1.6"] = BigDecimal(0,6)
    fieldWeights["1.7"] = BigDecimal(0,6)
    fieldWeights["1.8"] = BigDecimal(0,6)

    fieldWeights["2.1"] = BigDecimal(0,6)
    fieldWeights["2.2"] = BigDecimal(0,6)
    fieldWeights["2.3.1"] = BigDecimal(0,6)
    fieldWeights["2.3.2"] = BigDecimal(0,6)
    fieldWeights["2.3.3"] = BigDecimal(0,6)

    fieldWeights["3.1.1"] = BigDecimal(0,6)
    fieldWeights["3.1.2"] = BigDecimal(0,6)
    fieldWeights["3.2.1"] = BigDecimal(0,6)
    fieldWeights["3.2.2"] = BigDecimal(0,6)
    fieldWeights["3.2.3"] = BigDecimal(0,6)
    fieldWeights["3.3"] = BigDecimal(0,6)
    fieldWeights["3.4"] = BigDecimal(0,6)

    fieldWeights["4.1"] = BigDecimal(0,6)
    fieldWeights["4.2"] = BigDecimal(0,6)
    fieldWeights["4.3"] = BigDecimal(0,6)
    fieldWeights["4.4.1.1"] = BigDecimal(0,6)
    fieldWeights["4.4.1.2"] = BigDecimal(0,6)
    fieldWeights["4.4.1.3"] = BigDecimal(0,6)
    fieldWeights["4.4.1.4"] = BigDecimal(0,6)
    fieldWeights["4.5"] = BigDecimal(0,6)
    fieldWeights["4.6"] = BigDecimal(0,6)
    fieldWeights["4.7"] = BigDecimal(0,6)

    fieldWeights["5.1"] = BigDecimal(0,6)
    fieldWeights["5.2"] = BigDecimal(0,6)
    fieldWeights["5.3"] = BigDecimal(0,6)
    fieldWeights["5.4"] = BigDecimal(0,6)

    fieldWeights["5.5"] = BigDecimal(0,6)
    fieldWeights["5.6"] = BigDecimal(0,6)
    fieldWeights["5.7"] = BigDecimal(0,6)
    fieldWeights["5.8"] = BigDecimal(0,6)
    fieldWeights["5.9"] = BigDecimal(0,6)
    fieldWeights["5.10"] = BigDecimal(0,6)
    fieldWeights["5.11"] = BigDecimal(0,6)

    fieldWeights["6.1"] = BigDecimal(0,6)
    fieldWeights["6.2"] = BigDecimal(0,6)
    fieldWeights["6.3"] = BigDecimal(0,6)

    fieldWeights["7.1"] = BigDecimal(0,6)
    fieldWeights["7.2.1.1"] = BigDecimal(0,6)
    fieldWeights["7.2.1.2"] = BigDecimal(0,6)
    fieldWeights["7.2.2"] = BigDecimal(0,6)

    fieldWeights["8.1"] = BigDecimal(0,6)
    fieldWeights["8.2"] = BigDecimal(0,6)
    fieldWeights["8.3"] = BigDecimal(0,6)

    fieldWeights["9.1"] = BigDecimal(0,6)
    fieldWeights["9.2.1"] = BigDecimal(0,6)
    fieldWeights["9.2.2.1"] = BigDecimal(0,6)
    fieldWeights["9.2.2.2"] = BigDecimal(0,6)
    fieldWeights["9.3"] = BigDecimal(0,6)
    fieldWeights["9.4"] = BigDecimal(0,6)

    fieldWeights
  end

end