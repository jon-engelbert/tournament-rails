class TourneyService
  def self.is_round_complete tourney_id, round
    #go through all matches, match is complete if it is a bye or if scores have been recorded.
    tourney = Tourney.find(tourney_id)
    matches = Match.where(tourney: tourney_id, round: round)
    is_incomplete = false
    match_player_ids = Set.new
    matches.each do |match|
      match_player_ids << match.player1_id
      match_player_ids << match.player2_id
    end
    tourney.players.each do |entrant|
      is_incomplete ||=  !(match_player_ids.include? entrant.id)
      # puts "*************** is_incomplete 1 #{is_incomplete}"
    end
    entrants_unmatched = []
    tourney.players.each do |entrant|
      if !match_player_ids.include? entrant.id
        entrants_unmatched << entrant
        # puts "entrants_unmatched: #{entrants_unmatched}"
      end
    end
    is_incomplete = !entrants_unmatched.empty?
      # puts "*************** is_incomplete 2 #{is_incomplete}"
    matches.each do |match|
      is_incomplete ||= !match.bye && match.player1_score == 0 && match.player2_score == 0 && match.ties == 0
      # puts "*************** is_incomplete 3 #{is_incomplete}"
    end
    !is_incomplete
  end


  def self.generate_brackets_next tourney_id, good_enough_penalty
    # in response to user clicking on "generate next round".
    # if current round is complete, then proceed.
    # match up players by ranking according to standings
    # don't match up players who have played each other before
    # don't give a player two byes
    puts "******!!!!!!!!*********!!!!!!! in self.generate_brackets_next"
    tourney = Tourney.find(tourney_id)
    players = tourney.players
    matches = []
    max_round = Match.where(tourney: tourney_id).maximum(:round)
    max_round = 0 if max_round.nil?
    current_round_match_player_ids = get_unique_complete_player_ids(tourney_id, max_round, true)
    puts "************** current_round_match_player_ids #{current_round_match_player_ids.inspect}"
    players_unmatched = []
    puts "************** Players: #{players.inspect}"
    players.each do |player|
      if !current_round_match_player_ids.include? player.id
        players_unmatched << player
      end
    end
    puts "************** players_unmatched #{players_unmatched}"
    if is_round_complete(tourney_id, max_round)
      standings_unmatched = tourney.generate_standings
      puts "**********************standings_unmatched: #{standings_unmatched}"
      pairs, bye_player = tourney.generate_optimal_pairing_exhaustive standings_unmatched, good_enough_penalty
      puts "******!!!!!!!!!!!********!!!!!!!!!!!******** in self.generate_brackets_next, bye_player: #{bye_player}"
    else
      return nil, nil
    end
    match_records = Match.where(tourney: tourney_id).order(:round)

    player1, player2 = pairs.transpose
    scores1, scores2, ties = [0] * pairs.length, [0] * pairs.length, [0] * pairs.length
    rounds = [max_round+1] * pairs.length
    if player1.present? && player2.present?
      match_data = player1.zip(player2, scores1, scores2, ties, rounds)
      match_data.each do |data|
        # puts "******!!!!!!******* data: #{data.inspect}"
        parms = {tourney_id: tourney_id, player1_id: data[0][:player_id], player2_id: data[1][:player_id], player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5], bye: false}
        match = Match.new parms
        puts "*******!!!!!!!******** in generate_brackets_next, about to save: #{match.inspect}"
        match.save
        match.player1_name = data[0][:name]
        match.player2_name = data[1][:name]
        matches << match
      end
    end
    if bye_player
      puts "********!!!!!!!!********* in generate_brackets_next, about to add bye_player, #{bye_player.inspect}"
      parms = {tourney_id: tourney_id, player1_id: bye_player[:player_id], player2_id: bye_player[:player_id], player1_score: 0, player2_score: 0, ties: 0, round: max_round+1, bye: true}
      match = Match.new parms
      puts "********!!!!!!!!********* in generate_brackets_next, about to add bye_player match, #{match.inspect}"
      match.save
      matches << match
    end

    match_records.each do |match|
      puts "*******!!!!!!!******** in generate_brackets_next, #{match.inspect}"
      match.player1_name = Player.find_by(id: match.player1_id).name
      match.player2_name = Player.find_by(id: match.player2_id).name
      matches << match
    end
    return matches, bye_player
  end

  def self.get_unique_complete_player_ids tourney_id, round, include_byes
    match_player_ids = Set.new
    match_records = Match.where(tourney: tourney_id, round: round, bye: false)
    match_records.each do |match|
      match_player_ids << match.player1_id
      match_player_ids << match.player2_id
    end
    if include_byes
      bye_match_record = Match.where(tourney: tourney_id, round: round, bye: true)
      match_player_ids << bye_match_record[0].player1_id if bye_match_record.present?
    end
    match_player_ids
  end

  def self.remove_bye_matches tourney_id, round
    Match.where(tourney: tourney_id, round: round, bye: true).destroy_all
  end



  # GET /tourneys/1/brackets_initial
  def self.generate_brackets_initial tourney_id
    tourney = Tourney.find(tourney_id)
    players = Player.all()
    match_player_ids = Set.new
    match_records = Match.where(tourney: tourney_id).where("round <= 0")
    match_records.each do |match|
      match_player_ids << match.player1_id
      match_player_ids << match.player2_id
    end

    entrants_unmatched = []
    tourney.players.each do |entrant|
      if !match_player_ids.include? entrant.id
        entrants_unmatched << entrant
      end
    end

    # @entrants = @tourney.players()
    matches = []
    match_records = Match.where(tourney: tourney.id, round: 0)
    pairs, bye_player = tourney.swiss_pairings_initial entrants_unmatched
    player1, player2 = pairs.transpose
    scores1, scores2, ties = [0] * pairs.length, [0] * pairs.length, [0] * pairs.length
    round = [0] * pairs.length
    if player1.present?
      match_data = player1.zip(player2, scores1, scores2, ties, round)
      match_data.each do |data|
        parms = {tourney_id: tourney_id, player1_id: data[0][:player_id], player2_id: data[1][:player_id], player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5]}
        match = Match.new parms
        match.save
        match.player1_name = data[0].name
        match.player2_name = data[1].name
        matches << match
      end
    end
    match_records.each do |match|
      match.player1_name = Player.find_by(id: match.player1_id).name
      match.player2_name = Player.find_by(id: match.player2_id).name
      matches << match
    end
    return matches, bye_player
  end

  # GET /standings
  # GET /standings.json


end
