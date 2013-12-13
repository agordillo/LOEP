class Lo < ActiveRecord::Base
  attr_accessible :callback, :categories, :description, :name, :repository, :technology, :lan, :lotype, :url, :hasText, :hasImages, :hasVideos, :hasAudios, :hasQuizzes, :hasWebs, :hasFlashObjects, :hasApplets, :hasDocuments, :hasFlashcards, :hasVirtualTours, :hasEnrichedVideos, :tag_list

  validates :url,
  :presence => true,
  :uniqueness => {
    :case_sensitive => false
  }

  validates :name,
  :presence => true,
  :length => { :in => 3..255 },
  :uniqueness => {
    :case_sensitive => false
  }

  validates :lan,
  :presence => true,
  :exclusion => { in: "Unspecified", message: "has to be specified" }

  validates :lotype,
  :presence => true,
  :exclusion => { in: "Unspecified", message: "has to be specified" }

  validates :technology,
  :presence => true,
  :exclusion => { in: "Unspecified", message: "has to be specified" }

  acts_as_taggable

  has_many :assignments, :dependent => :destroy
  has_many :users, through: :assignments
  has_many :evaluations, :dependent => :destroy

  def getCategories
  	unless self.categories.nil?
  		begin
  			JSON(self.categories)
  		rescue
  			[]
  		end
  	end
  end

end
