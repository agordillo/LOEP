class Lo < ActiveRecord::Base
  attr_accessible :callback, :categories, :description, :hasQuizzes, :name, :repository, :technology, :lotype, :url, :hasText, :hasImages, :hasVideos, :hasAudios, :hasWebs, :hasFlashObjects, :hasApplets, :hasDocuments, :hasFlashcards, :hasVirtualTours, :hasEnrichedVideos

  def getCategories
  	unless self.categories.nil?
  		JSON(self.categories)
  	end
  end

end
