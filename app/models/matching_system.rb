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
            assignments << createMatch(loToReview,reviewer,assignmentParams,nil)

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
    assignments = [];

    reviewerLOmatchings = Hash.new
    # reviewerLOmatchings["reviewerId"] = ["loId1","loId2", ...]

    loNassignments = Hash.new
    # loNassignments["loId"] = nAssignments

    amatrix = Hash.new;
    # Suitability Matrix amatrix["reviewerId"]["loId"] = MatchingScore(lo,reviewer)

    reviewers.each do |reviewer|
      reviewer_matrix = Hash.new;
       # reviewer_matrix["loId"] = MatchingScore(lo,reviewer)
      los.each do |lo|
        reviewer_matrix[lo.id] = getMatchingScore(lo,reviewer)
      end
      amatrix[reviewer.id] = reviewer_matrix
    end

    reviewers.shuffle

    if nepl > reviewers.length
      #Is not possible
      #A reviewer can review a LO only once
      nepl = reviewers.length
    end

    while(los.length != 0)
      reviewers.each do |reviewer|
          if reviewerLOmatchings[reviewer.id].nil?
            reviewerLOmatchings[reviewer.id] = [];
          end

          loIdToReview = amatrix[reviewer.id].sort {|a1,a2| a2[1]<=>a1[1]}.first[0]
          loToReview = Lo.find(loIdToReview)

          #Remove LO from Reviewers matrix
          amatrix[reviewer.id].delete loToReview.id

          if !reviewerLOmatchings[reviewer.id].include?(loToReview.id)
            assignments << createMatch(loToReview,reviewer,assignmentParams,amatrix[reviewer.id][loToReview.id])

            reviewerLOmatchings[reviewer.id].push(loToReview.id);
            if loNassignments[loToReview.id].nil?
              loNassignments[loToReview.id] = 0
            end
            loNassignments[loToReview.id] = loNassignments[loToReview.id] + 1

            if loNassignments[loToReview.id] >= nepl
              #Remove LO from all hashes
              los = los.reject { |lo| lo.id == loToReview.id }
              reviewers.each do |reviewer|
                amatrix[reviewer.id].delete loToReview.id
              end
              if los.length === 0
                break
              end
            end
          end
      end
    end

    return assignments
  end

  # Prioritize reviewer suitability
  # Choose the most appropriate Reviewer for each LO
  def self.pReviewerA(nepl,los,reviewers,assignmentParams)
    return nil
  end

  def self.createMatch(lo,reviewer,assignmentParams,suitability)
    as = Assignment.new
    as.assign_attributes(assignmentParams)
    as.user_id = reviewer.id
    as.lo_id = lo.id
    as.status = "Pending"
    if suitability.nil?
      as.suitability = getMatchingScore(lo,reviewer)
    else
      as.suitability = suitability
    end
    return as
  end

  def self.getMatchingScore(lo,reviewer)
    score = 0
    score = score + getLanguageScore(lo,reviewer)
    score = score + getTagsSimilarityScore(lo,reviewer)
    return score
  end

  def self.getLanguageScore(lo,reviewer)
    lanScore = 0
    if lo.language === reviewer.language
      #Preferred or Native language match
      lanScore = lanScore + 1000
    elsif reviewer.languages.include? lo.language
      # LO is an understandable language for the reviewer
      lanScore = lanScore + 500
    else
      # Reviewer may not understand the LO
      lanScore = lanScore - 500
    end
    lanScore
  end

  def self.getTagsSimilarityScore(lo,reviewer)
    tagScore = 0
    
    reviewer.tags.each do |tag|
      if lo.tags.include? tag
        tagScore = tagScore + 150
      end
    end

    tagScore
  end

end
