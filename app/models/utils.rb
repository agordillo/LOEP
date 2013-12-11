# encoding: utf-8

class Utils < ActiveRecord::Base

  def self.getOptionsForSelectLan(action)
    languages = [["English","en"],["Español","es"],["German","de"],["Nederlands","nl"],["Magyar","hu"],["Français","fr"]]

    if action == "new" or action == "create"
      return languages.push(["Unspecified","Unspecified"])
    else
      return languages
    end
  end

	def self.readable_lan(lan)
    getOptionsForSelectLan(nil).each do |array|
      if array[1] == lan
        return array[0]
      end
    end
    "Unspecified"
  end

end