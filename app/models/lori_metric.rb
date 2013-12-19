class LoriMetric < Metric
  # this is for Metrics with evMethod=LORI (type=LoriMetric)
  #Override methods here

  def self.getItemWeights
  	itemWs = []
  	9.times do |i|
  		itemWs.push(Loric.average("item"+(i+1).to_s).to_f.round(2))
  	end

  	itemWSum = 0
  	itemWs.each do |w|
  		itemWSum = itemWSum + w
  	end
  	#Store Weight sum in the 10 position
  	itemWs.push(itemWSum)

  	itemWs
  end

  def self.getScoreForLos(los)
  	scores = Hash.new
  	itemWs = self.getItemWeights
  	los.each do |lo|
  		scores[lo.id.to_s] = _getScoreForLo(lo,itemWs)
  	end
  	scores
  end

  def self.getScoreForLo(lo)
  	return getScoreForLos([lo])[lo.id.to_s]
  end

  def self._getScoreForLo(lo,itemWs)
  	evaluations = lo.evaluations.where(:evmethod_id => Evmethod.find_by_name("LORI v1.5").id)
  	if evaluations.length === 0
  		return nil
  	end
  	score = 0
  	9.times do |i|
  		if evaluations.average("item"+(i+1).to_s).to_f.round(2) == 0
  			#Means that this item has not been evaluated in any evaluation
  			#All evaluations have leave this item in blank
  			return nil
  		end
  		score = score + ([evaluations.average("item"+(i+1).to_s).to_f.round(2),1].max-1) * itemWs[i]
  	end
  	score = ((5/(2*itemWs[9])) * score).round(2)
  end

end