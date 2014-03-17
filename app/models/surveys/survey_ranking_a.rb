class Surveys::SurveyRankingA < ActiveRecord::Base
  attr_accessible :results
  validates :results, :presence => true
end
