# LOM Metadata Quality Metric

class Metrics::LomMetadata < Metrics::WAM
  # this is for Metrics with type=Metadata
  #Override methods here

  def self.getLoScore(evData)
    super
  end

  def self.itemWeights
    [
      BigDecimal(1/3.to_f,8),
      BigDecimal(1/3.to_f,8),
      BigDecimal(1/3.to_f,8)
    ]
  end

  def self.fieldWeights
    fieldWeights = {}

    fieldWeights["1.1.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["1.1.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["1.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["1.3"] = BigDecimal(1/58.to_f,8)
    fieldWeights["1.4"] = BigDecimal(1/58.to_f,8)
    fieldWeights["1.5"] = BigDecimal(1/58.to_f,8)
    fieldWeights["1.6"] = BigDecimal(1/58.to_f,8)
    fieldWeights["1.7"] = BigDecimal(1/58.to_f,8)
    fieldWeights["1.8"] = BigDecimal(1/58.to_f,8)

    fieldWeights["2.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["2.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["2.3.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["2.3.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["2.3.3"] = BigDecimal(1/58.to_f,8)

    fieldWeights["3.1.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["3.1.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["3.2.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["3.2.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["3.2.3"] = BigDecimal(1/58.to_f,8)
    fieldWeights["3.3"] = BigDecimal(1/58.to_f,8)
    fieldWeights["3.4"] = BigDecimal(1/58.to_f,8)

    fieldWeights["4.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.3"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.4.1.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.4.1.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.4.1.3"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.4.1.3"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.5"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.6"] = BigDecimal(1/58.to_f,8)
    fieldWeights["4.7"] = BigDecimal(1/58.to_f,8)

    fieldWeights["5.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.3"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.4"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.5"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.6"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.7"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.8"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.9"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.10"] = BigDecimal(1/58.to_f,8)
    fieldWeights["5.11"] = BigDecimal(1/58.to_f,8)

    fieldWeights["6.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["6.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["6.3"] = BigDecimal(1/58.to_f,8)

    fieldWeights["7.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["7.2.1.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["7.2.1.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["7.2.2"] = BigDecimal(1/58.to_f,8)

    fieldWeights["8.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["8.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["8.3"] = BigDecimal(1/58.to_f,8)

    fieldWeights["9.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["9.2.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["9.2.2.1"] = BigDecimal(1/58.to_f,8)
    fieldWeights["9.2.2.2"] = BigDecimal(1/58.to_f,8)
    fieldWeights["9.3"] = BigDecimal(1/58.to_f,8)
    fieldWeights["9.4"] = BigDecimal(1/58.to_f,8)

    fieldWeights
  end

end