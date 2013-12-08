class Lo < ActiveRecord::Base
  attr_accessible :callback, :category, :description, :hasQuizzes, :name, :repository, :technology, :type, :url
end
