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

  # Strategy 1
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
          suitability = getMatchingScore(loToReview,reviewer)
          assignments << createMatch(loToReview,reviewer,assignmentParams,suitability)

          matchings[reviewer.id].push(loToReview.id);
          los.first[1] += 1
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

  # Strategy 2
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
          suitability = amatrix[reviewer.id][loToReview.id]
          assignments << createMatch(loToReview,reviewer,assignmentParams,suitability)

          reviewerLOmatchings[reviewer.id].push(loToReview.id);
          if loNassignments[loToReview.id].nil?
            loNassignments[loToReview.id] = 0
          end
          loNassignments[loToReview.id] += 1

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

  # Strategy 3
  # Prioritize reviewer suitability
  # Choose the most appropriate Reviewer for each LO
  def self.pReviewerA(nepl,los,reviewers,assignmentParams)
    assignments = [];

    amatrix = Hash.new;
    # Suitability Matrix amatrix["loId"]["reviewerId"] = MatchingScore(lo,reviewer)
    los.each do |lo|
      lo_matrix = Hash.new;
       # lo_matrix["reviewerId"] = MatchingScore(lo,reviewer)
      reviewers.each do |reviewer|
        lo_matrix[reviewer.id] = getMatchingScore(lo,reviewer)
      end
      amatrix[lo.id] = lo_matrix
    end

    if nepl > reviewers.length
      #Is not possible
      #A reviewer can review a LO only once
      nepl = reviewers.length
    end

    los.each do |lo|
      bestReviewers = amatrix[lo.id].sort{|a1,a2| a2[1]<=>a1[1]}
      nepl.times do |i|
        reviewerId = bestReviewers[i][0]
        reviewer = User.find(reviewerId)
        suitability = amatrix[lo.id][reviewer.id]
        assignments << createMatch(lo,reviewer,assignmentParams,suitability)
      end
    end

    return assignments
  end


  ########## 
  # Utils
  ##########

  # Create assignment for a specific match.
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


  ########## 
  # Matching Metric. Similarity between the lo and the reviewer.
  # The matching metric is a value between 0 and 100.
  ##########

  def self.getMatchingScore(lo,reviewer)
    weights = {:language => 0.8, :tags => 0.2}
    score = (weights[:language] * getLanguageScore(lo,reviewer) + weights[:tags] * getTagsSimilarityScore(lo,reviewer))
    return score
  end

  # The language score is a value between 0 and 100.
  def self.getLanguageScore(lo,reviewer)
    if lo.language === reviewer.language
      #Preferred or Native language match
      return 100
    elsif reviewer.languages.include? lo.language
      # LO is an understandable language for the reviewer
      return 90
    else
      # Reviewer may not understand the LO
      return 0
    end
  end

  # The tag similarity score is a value between 0 and 100.
  def self.getTagsSimilarityScore(lo,reviewer)
    if lo.tags.blank?
      return 0
    end

    similarTags = 0
    reviewer.tags.each do |tag|
      if lo.tags.include? tag
        similarTags += 1
      end
    end

    return ((similarTags/lo.tags.length.to_f)*100)
  end

end
