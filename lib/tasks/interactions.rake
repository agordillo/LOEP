# encoding: utf-8

namespace :interactions do

  #How to use: bundle exec rake interactions:updateThresholds
  #In production: bundle exec rake interactions:updateThresholds RAILS_ENV=production
  task :updateThresholds => :environment do |t, args|
    puts "Updating Interaction Thresholds"
    thresholdKeys = Metrics::QinteractionItem.thresholds.map{|k,v| k}
    losWithIteractions = Lo.includes("lo_interaction").where("lo_interactions.lo_id is not NULL")
    
    LOEP::Application.config.repositories.each do |repository|
      if repository.nil?
        los = losWithIteractions
      else
        los = losWithIteractions.where("repository='" + repository + "'")
      end
      next if los.blank?

      interactions = los.map{|lo| lo.lo_interaction.extended_attributes}
      iTimes = []
      iPermanencyRates = []
      iClickFrequencies = []
      interactions.each do |i|
        if i["tlo"].is_a? Hash and i["tlo"]["average_value"].is_a? Numeric and i["tlo"]["average_value"] > 0
          iTimes << i["tlo"]["average_value"]
          iClickFrequencies << (i["nclicks"]["average_value"]/(i["tlo"]["average_value"]/60.to_f).to_f) if i["nclicks"].is_a? Hash and i["nclicks"]["average_value"].is_a? Numeric
        end
        iPermanencyRates << i["permanency_rate"]["average_value"] if i["permanency_rate"].is_a? Hash and i["permanency_rate"]["average_value"].is_a? Numeric
      end

      require 'descriptive_statistics/safe'
      thresholdTimes = DescriptiveStatistics.percentile(80,iTimes).round(2)
      thresholdPermanencyRates = DescriptiveStatistics.percentile(80,iPermanencyRates).round(2)
      thresholdClickFrequencies = DescriptiveStatistics.percentile(80,iClickFrequencies).round(2)

      thresholdKeys.each do |thresholdKey|
        setting = Setting.where(:key => thresholdKey, :repository => repository).first
        setting = Setting.new(:key => thresholdKey, :repository => repository) if setting.blank?
        case thresholdKey
        when "Metrics::QinteractionTime"
          thresholdValue = thresholdTimes
        when "Metrics::QinteractionPermanency"
          thresholdValue = thresholdPermanencyRates
        when "Metrics::QinteractionClickFrequency"
          thresholdValue = thresholdClickFrequencies
        else
          thresholdValue = nil
        end
        setting.value = thresholdValue
        setting.save!
      end
    end

    puts "Task finished"
  end

end

 