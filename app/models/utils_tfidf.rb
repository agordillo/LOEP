# encoding: utf-8

class UtilsTfidf

  def self.processFreeText(text)
    return {} if text.blank?
    words = Hash.new
    normalizeText(text).split(" ").each do |word|
      words[word] = 0 if words[word].nil?
      words[word] += 1
    end
    words
  end

  def self.normalizeText(text)
    I18n.transliterate(text.gsub(/([\n])/," ").downcase.strip, :locale => "en")
  end

  def self.normalizeArray(array)
    return [] unless array.is_a? Array
    array.reject{|s| s.blank?}.map{|s| normalizeText(s)}.uniq
  end

  # Term Frequency (TF)
  def self.TF(word,text)
    processFreeText(text)[normalizeText(word)] || 0
  end

  # Inverse Document Frequency (IDF)
  def self.IDF(word,options={})
    totalEntries = LOEP::Application.config.total_entries[options[:repository]]
    return 1 if totalEntries.nil? or totalEntries < 2 #disable IDF (for first LO in repository)
    Math::log(totalEntries/(1+(LOEP::Application.config.words[options[:repository]][word] || 0 rescue 0)).to_f)
  end

  # TF-IDF
  def self.TFIDF(word,text,options={})
    tf = options[:tf] || TF(word,text)
    return 0 if tf==0
    return (tf * IDF(word,options))
  end

  def self.TFIDFFreeText(freeText,options={})
    freeTextTFIDF = 0
    processFreeText(freeText).each do |word,occurrences|
      freeTextTFIDF += TFIDF(word,freeText,options.merge({:tf => occurrences}))
    end
    freeTextTFIDF
  end

  #Semantic distance in a [0,1] scale.
  #It calculates the semantic distance using the Cosine similarity measure, and the TF-IDF function to calculate the vectors.
  def self.getSemanticDistance(textA,textB,options={})
    return 0 if (textA.blank? or textB.blank?)

    #We need to limit the length of the text due to performance issues
    textA = textA.first(LOEP::Application::config.max_text_length)
    textB = textB.first(LOEP::Application::config.max_text_length)

    numerator = 0
    denominator = 0
    denominatorA = 0
    denominatorB = 0

    wordsTextA = processFreeText(textA)
    wordsTextB = processFreeText(textB)

    if options[:words] == "min"
      words = [wordsTextA.keys, wordsTextB.keys].sort_by{|words| words.length}.first.uniq
    else
      words = wordsTextA.merge(wordsTextB).keys
    end
    
    words.each do |word|
      wordIDF = IDF(word,options)
      tfidf1 = (wordsTextA[word] || 0) * wordIDF
      tfidf2 = (wordsTextB[word] || 0) * wordIDF
      numerator += (tfidf1 * tfidf2)
      denominatorA += tfidf1**2
      denominatorB += tfidf2**2
    end

    denominator = Math.sqrt(denominatorA) * Math.sqrt(denominatorB)
    return 0 if denominator==0

    numerator/denominator
  end

end