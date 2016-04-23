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

  # Term Frequency (TF)
  def self.TF(word,text)
    processFreeText(text)[normalizeText(word)] || 0
  end

  # Inverse Document Frequency (IDF)
  def self.IDF(word,options={})
    Math::log((LOEP::Application.config.total_entries[options[:repository]] || 1)/(1+(LOEP::Application.config.words[options[:repository]][word] || 0 rescue 0)).to_f)
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

end