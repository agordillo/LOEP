# encoding: utf-8
STATS_FILE_PATH = "reports/stats.txt"

namespace :stats do

  #Usage
  #Development:   bundle exec rake stats:all
  task :all => :environment do
    Rake::Task["stats:prepare"].invoke
    Rake::Task["stats:evaluations"].invoke(false)
  end

  task :prepare do
    require "#{Rails.root}/lib/task_utils"
  end

  #Usage
  #Development:   bundle exec rake stats:evaluations
  task :evaluations, [:prepare] => :environment do |t,args|
    args.with_defaults(:prepare => true)
    Rake::Task["stats:prepare"].invoke if args.prepare

    puts "Evaluations Stats"

    allDates = []
    allEvaluationsByDate = []
    allLosByDate = []
    for year in 2012..2016
      12.times do |index|
        month = index+1
        # date = DateTime.new(params[:year],params[:month],params[:day])
        startDate = DateTime.new(year,month,1)
        endDate = startDate.next_month
        evaluations = Evaluation.where(:created_at => startDate..endDate)
        los = Lo.where(:created_at => startDate..endDate)
        allDates.push(startDate.strftime("%B %Y"))
        allEvaluationsByDate.push(evaluations)
        allLosByDate.push(los)
      end
    end

    #Created evaluations
    createdHumanEvaluations = []
    accumulativeCreatedHumanEvaluations = []
    createdAutomaticEvaluations = []
    accumulativeCreatedAutomaticEvaluations = []
    createdAutomaticBEvaluations = []
    accumulativeCreatedAutomaticBEvaluations = []
    allEvaluationsByDate.each_with_index do |evaluations,index|
      lastAcCreatedHuman = (index > 0 ? accumulativeCreatedHumanEvaluations[index-1] : 0)
      nHumanCreated = evaluations.human.count
      createdHumanEvaluations.push(nHumanCreated)
      accumulativeCreatedHumanEvaluations.push(lastAcCreatedHuman + nHumanCreated)

      lastAcCreatedAutomatic = (index > 0 ? accumulativeCreatedAutomaticEvaluations[index-1] : 0)
      nAutomaticCreated = evaluations.automatic.count
      createdAutomaticEvaluations.push(nAutomaticCreated)
      accumulativeCreatedAutomaticEvaluations.push(lastAcCreatedAutomatic + nAutomaticCreated)

      lastAcCreatedAutomaticB = (index > 0 ? accumulativeCreatedAutomaticBEvaluations[index-1] : 0)
      nAutomaticBCreated = allLosByDate[index].map{|lo| lo.evaluations.automatic.length}.sum
      createdAutomaticBEvaluations.push(nAutomaticBCreated)
      accumulativeCreatedAutomaticBEvaluations.push(lastAcCreatedAutomaticB + nAutomaticBCreated)
    end

    #Evaluations by ev method
    evmethods = []
    evaluationsByEvMethod = []
    Evmethod.all.each do |e|
      evmethods.push(e.name)
      evaluationsByEvMethod.push(Evaluation.where(:evmethod_id => e.id).count)
    end

    filePath = "reports/evaluations_stats.xlsx"
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Presentations Stats") do |sheet|
        rows = []
        rows << ["Evaluations Stats"]
        rows << ["Date","Created Evaluations (Human)","Accumulative Created Evaluations (Human)","Created Evaluations (Automatic)","Accumulative Created Evaluations (Automatic)","Created Evaluations (AutomaticB)","Accumulative Created Evaluations (AutomaticB)"]
        rowIndex = rows.length
        
        rows += Array.new(createdHumanEvaluations.length).map{|e|[]}
        createdHumanEvaluations.each_with_index do |n,i|
          rows[rowIndex+i] = [allDates[i],createdHumanEvaluations[i],accumulativeCreatedHumanEvaluations[i],createdAutomaticEvaluations[i],accumulativeCreatedAutomaticEvaluations[i],createdAutomaticBEvaluations[i],accumulativeCreatedAutomaticBEvaluations[i]]
        end

        rows << []
        rows << ["Evaluations by ev method"]
        rows << ["Ev Method","Number of evaluations"]
        rowIndex = rows.length
        rows += Array.new(evmethods.length).map{|e|[]}
        evmethods.each_with_index do |e,i|
          rows[rowIndex+i] = [e,evaluationsByEvMethod[i]]
        end

        rows.each do |row|
          sheet.add_row row
        end
      end

      prepareFile(filePath)
      p.serialize(filePath)

      puts("Task Finished. Results generated at " + filePath)
    end
  end

end
