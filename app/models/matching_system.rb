class MatchingSystem

  # criteria: #LO-Reviewer Matching Criteria
  def self.LoReviewerMatching(criteria,nepl,los,reviewers,assignmentParams)
    case criteria
    when "pwlRandom"
      return pwlRandom(nepl,los,reviewers,assignmentParams)
    when "pwlBestEffort"
      return pwlBestEffort(nepl,los,reviewers,assignmentParams)
    when "pReviewerA"
      return pReviewerA(nepl,los,reviewers,assignmentParams)
    else
      return nil
    end
  end


  private

  # Prioritize workload balancing: Random Matching
  # Same LOs for each reviewer, random 
  #
  # 1. Shuffle LOs
  # 2. Iterate Reviewers 
  def self.pwlRandom(nepl,los,reviewers,assignmentParams)
    assignments = [];

    matchings = Hash.new;
    # matchings["reviewerId"] = ["loId1","loId2", ...];

    # LO tuple [LO, nAssignments]
    los.shuffle
    los = los.map { |lo| [lo,0] };
    reviewers.shuffle

    if nepl > reviewers.length
      #Is not possible
      #A reviewer can review a LO only once
      nepl = reviewers.length
    end

    while(los.length != 0)
      reviewers.each do |reviewer|
          if matchings[reviewer.id].nil?
            matchings[reviewer.id] = [];
          end

          loToReview = los.first[0]

          if !matchings[reviewer.id].include?(loToReview.id)
            assignments << match(loToReview,reviewer,assignmentParams)

            matchings[reviewer.id].push(loToReview.id);
            los.first[1] = los.first[1] + 1
            if los.first[1] >= nepl
              los = los.reject { |lo| lo[0].id == loToReview.id }
              if los.length === 0
                break
              end
            end
          end
      end
    end

    return assignments
  end

  # Prioritize workload balancing: Best-effort Matching
  # Same LOs for each reviewer, try to choose the most appropriate LO for each reviewer
  def self.pwlBestEffort(nepl,los,reviewers,assignmentParams)
    return nil
  end

  # Prioritize reviewer appropriateness
  # Choose the most appropriate Reviewer for each LO
  def self.pReviewerA(nepl,los,reviewers,assignmentParams)
    return nil
  end

  def self.match(lo,reviewer,assignmentParams)
    as = Assignment.new
    as.assign_attributes(assignmentParams)
    as.user_id = reviewer.id
    as.lo_id = lo.id
    as.status = "Pending"
    return as
  end

  #A reviewer shouldn't review a LO more than once
  def self.isRepeatedAssignment(assignments,lo,reviewer)

  end

end
