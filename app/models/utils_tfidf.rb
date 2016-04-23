# encoding: utf-8

class UtilsTfidf

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

  def self.TFIDF(word,text,options={})
    if options[:occurrences].is_a? Numeric
      occurrencesOfWordInText = options[:occurrences]
    else
      occurrencesOfWordInText = processFreeText(text)[word] || 0
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

  def self.TFIDFFreeText(freeText,options)
    freeTextTFIDF = 0
    processFreeText(freeText).each do |word,occurrences|
      freeTextTFIDF += TFIDF(word,freeText,options.merge({:occurrences => occurrences}))
    end
    freeTextTFIDF
  end

end