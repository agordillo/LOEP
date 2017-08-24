# encoding: utf-8
STATS_FILE_PATH = "reports/stats.txt"

namespace :stats do

  #Usage
  #Development:   bundle exec rake stats:all
  task :all => :environment do
    Rake::Task["stats:prepare"].invoke
    Rake::Task["stats:evaluations"].invoke(false)
    Rake::Task["stats:evaluated_los"].invoke(false)
    Rake::Task["stats:users"].invoke(false)
    Rake::Task["stats:assignments"].invoke(false)
    Rake::Task["stats:scores"].invoke(false)
  end

  task :prepare do
    require "#{Rails.root}/lib/task_utils"
  end

  #Usage
  #Development:   bundle exec rake stats:general
  task :general, [:prepare] => :environment do |t,args|
    args.with_defaults(:prepare => true)
    Rake::Task["stats:prepare"].invoke if args.prepare
    puts "General Stats"

    #General vars
    startDate = DateTime.new(2000,1,1)
    endDate = DateTime.new(2060,1,1)
    repositoryNames = Lo.all.map{|lo| lo.repository}.uniq
    repositories = {}
    
    repositoryNames.each do |repositoryName|
      repositories[repositoryName] = {}
      repositories[repositoryName][:los] = Lo.where(:created_at => startDate..endDate, :repository => repositoryName)
      repositories[repositoryName][:lo_ids] = repositories[repositoryName][:los].map{|lo| lo.id}

      puts "Stats for repository " + (repositoryName || "nil")
      repositories[repositoryName]["elos"] = {}
      repositories[repositoryName]["evs"] = {}
      repositories[repositoryName]["assignments"] = {}
      repositories[repositoryName]["scores"] = {}
      Evmethod.all.each do |evmethod|
        evaluations = Evaluation.where("evmethod_id=" + evmethod.id.to_s + " and lo_id in (?)",repositories[repositoryName][:lo_ids])
        repositories[repositoryName]["elos"][evmethod.name] = evaluations.map{|e| e.lo}.uniq.length
        repositories[repositoryName]["evs"][evmethod.name] = evaluations.count
        assignments = Assignment.where("evmethod_id=" + evmethod.id.to_s + " and lo_id in (?)",repositories[repositoryName][:lo_ids])
        
        repositories[repositoryName]["assignments"][evmethod.name] = {}
        repositories[repositoryName]["assignments"][evmethod.name]["Total"] = assignments.count
        ["Pending", "Completed", "Rejected"].each do |status|
          repositories[repositoryName]["assignments"][evmethod.name][status] = assignments.where("status='"+status+"'").count
        end
      end
      Metric.all.each do |metric|
        scores = Score.where("metric_id=" + metric.id.to_s + " and lo_id in (?)",repositories[repositoryName][:lo_ids])
        repositories[repositoryName]["scores"][metric.name] = scores.count
      end

      repositories[repositoryName][:los] = []
      repositories[repositoryName][:lo_ids] = []
    end

    filePath = "reports/general_stats.xlsx"
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "General LOEP Stats") do |sheet|
        rows = []
        rows << ["LOEP General Stats by Repository"]
        repositoryNames.each do |repositoryName|
          rows << []
          rows << []
          rows << ["General Stats for Repository: " + repositoryName]
          rows << ["Evaluated LOs"]
          rows << ["EvMethod","Evaluated LOs"]
          repositories[repositoryName]["elos"].each do |key,value|
            rows << [key,value]
          end

          rows << []
          rows << ["Evaluations"]
          rows << ["EvMethod","Number of evaluations"]
          repositories[repositoryName]["evs"].each do |key,value|
            rows << [key,value]
          end

          rows << []
          rows << ["Assignments"]
          rows << ["EvMethod","Status","Number of assignments"]
          repositories[repositoryName]["assignments"].each do |key,value|
            ["Total", "Pending", "Completed", "Rejected"].each do |status|
              rows << [key,status,value[status]]
            end
          end

          rows << []
          rows << ["Scores"]
          rows << ["Metric","Number of scores"]
          repositories[repositoryName]["scores"].each do |key,value|
            rows << [key,value]
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
      nAutomaticCreated = allLosByDate[index].map{|lo| lo.evaluations.automatic.length}.sum
      createdAutomaticEvaluations.push(nAutomaticCreated)
      accumulativeCreatedAutomaticEvaluations.push(lastAcCreatedAutomatic + nAutomaticCreated)

      lastAcCreatedBAutomatic = (index > 0 ? accumulativeCreatedAutomaticBEvaluations[index-1] : 0)
      nAutomaticBCreated = evaluations.automatic.count
      createdAutomaticBEvaluations.push(nAutomaticBCreated)
      accumulativeCreatedAutomaticBEvaluations.push(lastAcCreatedBAutomatic + nAutomaticBCreated)
    end

    #Evaluations by ev method
    evmethods = []
    evaluationsByEvMethod = []
    Evmethod.all.each do |e|
      evmethods.push(e.name)
      evaluationsByEvMethod.push(Evaluation.where(:evmethod_id => e.id).count)
    end

    #Accumulated Evaluated LOs by repository
    repositories = Lo.all.map{|lo| lo.repository}.uniq
    createdHumanEvaluationsRepositories = {}
    accumulativeCreatedHumanEvaluationsRepositories = {}
    createdAutomaticEvaluationsRepositories = {}
    accumulativeCreatedAutomaticEvaluationsRepositories = {}
    repositories.each do |repository|
      createdHumanEvaluationsRepositories[repository] = []
      accumulativeCreatedHumanEvaluationsRepositories[repository] = []
      createdAutomaticEvaluationsRepositories[repository] = []
      accumulativeCreatedAutomaticEvaluationsRepositories[repository] = []
    end

    allEvaluationsByDate.each_with_index do |evaluations,index|
      repositories.each do |repository|
        lastAcCreatedHuman = (index > 0 ? accumulativeCreatedHumanEvaluationsRepositories[repository][index-1] : 0)
        nHumanCreated = evaluations.human.select{|e| e.lo.repository==repository}.count
        createdHumanEvaluationsRepositories[repository].push(nHumanCreated)
        accumulativeCreatedHumanEvaluationsRepositories[repository].push(lastAcCreatedHuman + nHumanCreated)

        lastAcCreatedAutomatic = (index > 0 ? accumulativeCreatedAutomaticEvaluationsRepositories[repository][index-1] : 0)
        nAutomaticCreated = allLosByDate[index].select{|lo| lo.repository==repository}.map{|lo| lo.evaluations.automatic.length}.sum
        createdAutomaticEvaluationsRepositories[repository].push(nAutomaticCreated)
        accumulativeCreatedAutomaticEvaluationsRepositories[repository].push(lastAcCreatedAutomatic + nAutomaticCreated)
      end
    end

    #Evaluations by ev method and repository
    evaluationsByEvMethodAndRepository = {}
    repositories.each do |repository|
      evaluationsByEvMethodAndRepository[repository] = []
    end
    Evmethod.all.each do |e|
      repositories.each do |repository|
        mEvaluations = Lo.where(:repository => repository).map{|lo| lo.evaluations}.flatten.select{|ev| ev.evmethod_id == e.id}
        evaluationsByEvMethodAndRepository[repository].push(mEvaluations.length)
      end
    end


    filePath = "reports/evaluations_stats.xlsx"
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Evaluations Stats") do |sheet|
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

        repositories.each do |repository|
          rows << []
          rows << ["Repository: " + repository.to_s]
          rows << ["Evaluations Stats"]
          rows << ["Date","Created Evaluations (Human)","Accumulative Created Evaluations (Human)","Created Evaluations (Automatic)","Accumulative Created Evaluations (Automatic)"]
          rowIndex = rows.length

          rows += Array.new(createdHumanEvaluationsRepositories[repository].length).map{|e|[]}
          createdHumanEvaluationsRepositories[repository].each_with_index do |n,i|
            rows[rowIndex+i] = [allDates[i],createdHumanEvaluationsRepositories[repository][i],accumulativeCreatedHumanEvaluationsRepositories[repository][i],createdAutomaticEvaluationsRepositories[repository][i],accumulativeCreatedAutomaticEvaluationsRepositories[repository][i]]
          end

          rows << []
          rows << ["Evaluations by ev method"]
          rows << ["Ev Method","Number of evaluations"]
          rowIndex = rows.length
          rows += Array.new(evmethods.length).map{|e|[]}
          evmethods.each_with_index do |e,i|
            rows[rowIndex+i] = [e,evaluationsByEvMethodAndRepository[repository][i]]
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
      p.workbook.add_worksheet(:name => "LOs Stats") do |sheet|
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

  #Usage
  #Development:   bundle exec rake stats:users
  task :users, [:prepare] => :environment do |t,args|
    args.with_defaults(:prepare => true)
    Rake::Task["stats:prepare"].invoke if args.prepare

    puts "Users Stats"

    allUsers = User.all.sort{|b,a| a.compareUsers(b)}

    filePath = "reports/users_stats.xlsx"
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Users Stats") do |sheet|
        rows = []
        rows << ["Users Stats"]
        rows << ["Id","Role","Registration date","Evaluations","Assignments"]
        rowIndex = rows.length
        
        rows += Array.new(allUsers.length).map{|e|[]}
        allUsers.each_with_index do |u,i|
          rows[rowIndex+i] = [u.id.to_s,u.readable_role,u.created_at,u.evaluations.human.internal.count,u.assignments.count]
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
  #Development:   bundle exec rake stats:assignments
  task :assignments, [:prepare] => :environment do |t,args|
    args.with_defaults(:prepare => true)
    Rake::Task["stats:prepare"].invoke if args.prepare

    puts "Assignment Stats"

    allDates = []
    allAssignmentsByDate = []
    allAssignmentsBeforeDate = []
    for year in 2012..2016
      12.times do |index|
        month = index+1
        # date = DateTime.new(params[:year],params[:month],params[:day])
        startDate = DateTime.new(year,month,1)
        endDate = startDate.next_month
        assignments = Assignment.where(:created_at => startDate..endDate)
        allDates.push(startDate.strftime("%B %Y"))
        allAssignmentsByDate.push(assignments)
        allAssignmentsBeforeDate.push(Assignment.where("created_at < ?", endDate))
      end
    end

    #Created assignments
    createdAssignments = []
    accumulativeCreatedAssignments = []
    allAssignmentsByDate.each_with_index do |assignments,index|
      lastAcCreatedAssignments = (index > 0 ? accumulativeCreatedAssignments[index-1] : 0)
      nCreated = assignments.count
      createdAssignments.push(nCreated)
      accumulativeCreatedAssignments.push(lastAcCreatedAssignments + nCreated)
    end

    #Assignments by status
    aStatuses = Assignment.all.map{|a| a.status}.uniq
    accumulativeAssignmentsByStatus = {}
    aStatuses.each do |status|
      accumulativeAssignmentsByStatus[status] = []
    end
    allAssignmentsBeforeDate.each_with_index do |assignments,index|
      aStatuses.each do |status|
        accumulativeAssignmentsByStatus[status].push(assignments.where("status='"+status+"'").count)
      end
    end

    filePath = "reports/assignments_stats.xlsx"
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Assignments Stats") do |sheet|
        rows = []
        rows << ["Assignment Stats"]
        rows << (["Date","Created Assignments","Accumulative Created Assignments"] + aStatuses.map{|s| "Accumulative " + s + " Assignments" })
        rowIndex = rows.length
        
        rows += Array.new(createdAssignments.length).map{|e|[]}
        createdAssignments.each_with_index do |n,i|
          rows[rowIndex+i] = ([allDates[i],createdAssignments[i],accumulativeCreatedAssignments[i]] + aStatuses.map{|s| accumulativeAssignmentsByStatus[s][i] })
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
  #Development:   bundle exec rake stats:scores
  task :scores, [:prepare] => :environment do |t,args|
    args.with_defaults(:prepare => true)
    Rake::Task["stats:prepare"].invoke if args.prepare

    puts "Score Stats"

    allDates = []
    allManualScoresByDate = []
    allLosByDate = []
    for year in 2012..2016
      12.times do |index|
        month = index+1
        # date = DateTime.new(params[:year],params[:month],params[:day])
        startDate = DateTime.new(year,month,1)
        endDate = startDate.next_month
        scores = Score.where(:created_at => startDate..endDate).reject{|s| s.automatic?}
        allManualScoresByDate.push(scores)
        los = Lo.where(:created_at => startDate..endDate)
        allLosByDate.push(los)
        allDates.push(startDate.strftime("%B %Y"))
      end
    end

    #Automatic scores (These scores are generated when the LOs are registered)
    generatedAutomaticScores = []
    accumulativeAutomaticScores = []
    allLosByDate.each_with_index do |los,index|
      lastAcAutomaticScores = (index > 0 ? accumulativeAutomaticScores[index-1] : 0)
      automaticScores = los.map{|lo| lo.scores.select{|s| s.automatic?}.length}.sum
      generatedAutomaticScores.push(automaticScores)
      accumulativeAutomaticScores.push(lastAcAutomaticScores + automaticScores)
    end

    #Manual scores (These scores are generated when reviewers create complete evaluations for each of evmethods required by the metric of the score)
    generatedManualScores = []
    accumulativeManualScores = []
    allManualScoresByDate.each_with_index do |scores,index|
      lastAcManualScores = (index > 0 ? accumulativeManualScores[index-1] : 0)
      manualScores = scores.length
      generatedManualScores.push(manualScores)
      accumulativeManualScores.push(lastAcManualScores + manualScores)
    end


    #Total scores
    totalScores = []
    accumulativeTotalScores = []
    generatedAutomaticScores.each_with_index do |scores,index|
      totalScores.push(generatedAutomaticScores[index]+generatedManualScores[index])
      accumulativeTotalScores.push(accumulativeAutomaticScores[index]+accumulativeManualScores[index])
    end

    filePath = "reports/scores_stats.xlsx"
    prepareFile(filePath)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Scores Stats") do |sheet|
        rows = []
        rows << ["Scores Stats"]
        rows << ["Date","Generated Automatic Scores","Accumulative Automatic scores","Manual scores","Accumulative Manual scores","Total scores","Accumulative Total scores"]
        rowIndex = rows.length
        
        rows += Array.new(generatedAutomaticScores.length).map{|e|[]}
        generatedAutomaticScores.each_with_index do |n,i|
          rows[rowIndex+i] = [allDates[i],generatedAutomaticScores[i],accumulativeAutomaticScores[i],generatedManualScores[i],accumulativeManualScores[i],totalScores[i],accumulativeTotalScores[i]]
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