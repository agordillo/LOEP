# encoding: utf-8
STATS_FILE_PATH = "reports/stats.txt"

namespace :stats do

  #Usage
  #Development:   bundle exec rake stats:all
  task :all => :environment do
    Rake::Task["stats:prepare"].invoke
    Rake::Task["stats:evaluations"].invoke(false)
    Rake::Task["stats:evaluated_los"].invoke(false)
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

    #Accumulated Evaluated LOs
    accumulativeLos = []
    allLosByDate.each_with_index do |los,index|
      lastAcLos = (index > 0 ? accumulativeLos[index-1] : 0)
      accumulativeLos.push(lastAcLos + allLosByDate[index].length)
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

  #Usage
  #Development:   bundle exec rake stats:evaluated_los
  task :evaluated_los, [:prepare] => :environment do |t,args|
    args.with_defaults(:prepare => true)
    Rake::Task["stats:prepare"].invoke if args.prepare

    puts "Evaluations Stats"

    allDates = []
    allLosByDate = []
    allHLosByDate = []
    allAddedHLos = []
    for year in 2012..2016
      12.times do |index|
        month = index+1
        # date = DateTime.new(params[:year],params[:month],params[:day])
        startDate = DateTime.new(year,month,1)
        endDate = startDate.next_month
        allDates.push(startDate.strftime("%B %Y"))

        #LOs are automatically evaluated when they are registered
        #So, evaluated LOs (including automatic evaluations) and registered LOs are the same
        los = Lo.where(:created_at => startDate..endDate)
        allLosByDate.push(los)

        #LOs evaluated by humans through the time
        evaluations = Evaluation.where(:created_at => startDate..endDate)
        hEvaluations = evaluations.human
        hLos = (hEvaluations.map{|e| e.lo}.uniq - allAddedHLos)
        allAddedHLos = (allAddedHLos + hLos).uniq
        allHLosByDate.push(hLos)
      end
    end

    #Accumulated Evaluated LOs
    accumulativeLos = []
    accumulativeHLos = []
    allLosByDate.each_with_index do |los,index|
      lastAcLos = (index > 0 ? accumulativeLos[index-1] : 0)
      accumulativeLos.push(lastAcLos + allLosByDate[index].length)

      lastAcHLos = (index > 0 ? accumulativeHLos[index-1] : 0)
      accumulativeHLos.push(lastAcHLos + allHLosByDate[index].length)
    end

    #Accumulated Evaluated LOs by repository
    repositories = Lo.all.map{|lo| lo.repository}.uniq
    accumulativeLosRepositories = {}
    accumulativeHLosRepositories = {}
    repositories.each do |repository|
      accumulativeLosRepositories[repository] = []
      accumulativeHLosRepositories[repository] = []
    end
    allLosByDate.each_with_index do |los,index|
      repositories.each do |repository|
        lastAcLos = (index > 0 ? accumulativeLosRepositories[repository][index-1] : 0)
        accumulativeLosRepositories[repository].push(lastAcLos + allLosByDate[index].select{|lo| lo.repository==repository}.length)

        lastAcHLos = (index > 0 ? accumulativeHLosRepositories[repository][index-1] : 0)
        accumulativeHLosRepositories[repository].push(lastAcHLos + allHLosByDate[index].select{|lo| lo.repository==repository}.length)
      end
    end

    filePath = "reports/los_evaluated_stats.xlsx"
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Presentations Stats") do |sheet|
        rows = []
        rows << ["LOs Stats"]
        rows << ["Date","Evaluated LOs","Evaluated LOs (Human)"]
        rowIndex = rows.length
        
        rows += Array.new(accumulativeLos.length).map{|e|[]}
        accumulativeLos.each_with_index do |n,i|
          rows[rowIndex+i] = [allDates[i],accumulativeLos[i],accumulativeHLos[i]]
        end

        rows << []
        rows << ["LOs Stats by Repository"]
        repositories.each do |repository|
          rows << []
          rows << ["LOs Stats for Repository: " + repository]
          rows << ["Date","Evaluated LOs","Evaluated LOs (Human)"]
          rowIndex = rows.length
          
          rows += Array.new(accumulativeLosRepositories[repository].length).map{|e|[]}
          accumulativeLosRepositories[repository].each_with_index do |n,i|
            rows[rowIndex+i] = [allDates[i],accumulativeLosRepositories[repository][i],accumulativeHLosRepositories[repository][i]]
          end
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
