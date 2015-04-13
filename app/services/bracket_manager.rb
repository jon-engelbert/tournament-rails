class BracketManager
	attr_accessor :tourney

	def initialize(tour)
		self.tourney = tour
	end

	def swiss_pairings_initial(players_in)
		mod = players_in.length % 2
		use_bye = ( mod!= 0)
		puts "players_in.length, mod, use_bye: #{players_in.length}, #{mod}, #{use_bye}"
		player_bye_id = nil
		if use_bye
		  bye_player = players_in.sample
		  puts "bye_player: #{bye_player.inspect}"
		end
		is_begin_pair = true
		pairs = []
		prev_player = nil
		players_in.shuffle.each do |player|
		  if player != bye_player
		    if is_begin_pair
		      prev_player = player
		      # puts "$$$$$$$$$ first #{prev_player.inspect}"
		    else
		      # puts "$$$$$$$$$ first #{prev_player.inspect}"
		      pair = [player, prev_player]
		      # puts "$$$$$$$$$ pair #{pair.inspect}"
		      pairs << pair
		      # puts "$$$$$$$$$ pairs #{pairs.inspect}"
		    end
		    is_begin_pair = !is_begin_pair
		  end
		end
		# puts "bye_player: #{bye_player.inspect}"
		return pairs, bye_player
	end

	def pairings_cost pairings, bye_player_hash, previous_matchups, max_round, player_count
		cost = 0
		matchup_conflicts = []
		pairings.each do |player1, player2|
		  cost += ((player1[:pts_per_match] - player2[:pts_per_match]) / tourney.points_win) ** 2
		  if previous_matchups.include?([player1[:player][:id], player2[:player][:id]]) || previous_matchups.include?([player2[:player][:id], player1[:player][:id]])
		    cost += player_count
		    matchup_conflicts << [player1[:player][:id], player2[:player][:id]]
		  end
		end
		puts "*******!!!!!!!! pairings_cost, bye_player_hash: #{cost}, #{bye_player_hash}"
		cost += (max_round - bye_player_hash[:total_matches]) * player_count * 2 if bye_player_hash.present?
		puts "*******!!!!!!!! pairings_cost, bye_player_hash: #{cost}, #{bye_player_hash}"
		return cost, matchup_conflicts
	end


  # generates matchups from standings
  # Params:
  # +player_standings+:: sorted array of hashes, the last value of each hash is the player object
	def generate_pairs_from_standings player_standings
		player_pairs = []
		bye_player_hash = {}
		bye_player = nil
		player_standings.each_slice(2) do |player_pair| 
		  if player_pair.size == 2
		    puts "In generate_optimal_pairing, player_pair : #{player_pair.inspect}"
		    player_pairs << player_pair
		  else
		    puts "In generate_optimal_pairing, player_pair (only one): #{player_pair.inspect}"
		    bye_player_hash = player_pair[0]
		    bye_player = bye_player_hash[:player]
		  end
		end
		return player_pairs, bye_player, bye_player_hash
	end

	def standings_moveup player_standings, position
		player_standings
	end

  # generates 'optimal' pairings for bracket, or at least close to optimal.
  # Params:
  # +player_standings+: sorted array of hashes, the last value of each hash is the player object
  # +good_enough_penalty+: if a potential pairing's penalty is less than this value, then it's good enough and accept it.
  # +is_exhaustive+: try out all permutations before picking the best one
  # Returns:
  # +min_cost_pairs+: the matchups
  # +min_cost_bye_player+: the lowest ranked player who is eligible for a bye
	def generate_optimal_pairing player_standings, good_enough_penalty, is_exhaustive
		puts "****!!!!!!!******!!!!!! in generate_optimal_pairing, player_standings count: #{player_standings.count}"
		max_round = Match.where(tourney_id: tourney.id).maximum(:round)
		max_round = 0 if max_round.nil?
		bye_player_hash = nil
		bye_player = nil
		player_pairs = []
		min_cost = player_standings.count ** 3 + 2
		min_cost_pairs = nil
		min_cost_bye_player = nil
		matches = Match.where(tourney_id: tourney.id).select {|match| match.player1_score > 0 || match.player2_score > 0 || match.ties > 0}
		previous_matchups = Match.matchups matches
		#first, try the standings in linear order
		  player_pairs, bye_player, bye_player_hash = generate_pairs_from_standings player_standings
		  cost, matchup_conflicts = pairings_cost(player_pairs, bye_player_hash, previous_matchups, max_round, player_standings.count)
		  if cost == 0
		    return player_pairs, bye_player
		  elsif cost < good_enough_penalty && matchup_conflicts.blank?
		    return player_pairs, bye_player
		  elsif (cost < min_cost)
		      min_cost_pairs = player_pairs
		      min_cost_bye_player = bye_player
		      min_cost = cost
		  end

		matchup_conflicts.each do |matchup_conflict|
		  #try moving each of the pair in the conflict, pick the set of matchups with the smallest error
		  player_pairs = standings_moveup player_pairs, matchup_conflict
		  cost, matchup_conflicts_new = pairings_cost(player_pairs, bye_player_hash, previous_matchups, max_round, player_standings.count)
		  puts "******!!!!!!!!!!!********!!!!!!!!!!!******** in generate_optimal_pairing, good_enough_penalty: #{good_enough_penalty}"
		  puts "******!!!!!!!!!!!********!!!!!!!!!!!******** in generate_optimal_pairing, cost: #{cost.inspect}"
		  if cost == 0
		    return player_pairs, bye_player
		  elsif (cost < good_enough_penalty)
		    return player_pairs, bye_player
		  elsif (cost < min_cost)
		      min_cost_pairs = player_pairs
		      min_cost_bye_player = bye_player
		      min_cost = cost
		  end
		end

		if player_standings.count > 6 && !is_exhaustive
		  samples = []
		  1000.times do
		    player_standings_temp =  player_standings.shuffle
		    player_pairs, bye_player, bye_player_hash = generate_pairs_from_standings player_standings_temp
		    cost, matchup_conflicts_new = pairings_cost(player_pairs, bye_player_hash, previous_matchups, max_round, player_standings.count)
		    if cost == 0
		      return player_pairs, bye_player
		    elsif cost < good_enough_penalty
		      return player_pairs, bye_player
		    elsif (cost < min_cost)
		        min_cost_pairs = player_pairs
		        min_cost_bye_player = bye_player
		        min_cost = cost
		    end
		  end
		else
		  player_standings.permutation.each do |player_standings_temp|
		    player_pairs, bye_player, bye_player_hash = generate_pairs_from_standings player_standings_temp
		    cost, matchup_conflicts_new = pairings_cost(player_pairs, bye_player_hash, previous_matchups, max_round, player_standings.count)
		    if cost == 0
		      return player_pairs, bye_player
		    elsif cost < good_enough_penalty
		      return player_pairs, bye_player
		    elsif (cost < min_cost)
		        min_cost_pairs = player_pairs
		        min_cost_bye_player = bye_player
		        min_cost = cost
		    end
		  end
		end
		return min_cost_pairs, min_cost_bye_player
	end

	def generate_brackets
		puts "************** In brackets"
		match_player_ids = Set.new
		match_records = Match.where(tourney_id: tourney.id)
		match_records.each do |match|
		  match_player_ids << match.player1_id
		  match_player_ids << match.player2_id
		end
		max_round = Match.where(tourney_id: tourney.id).maximum(:round)
		max_round = 0 if max_round.nil?
		current_round_match_player_ids = TourneyService.get_unique_complete_player_ids(tourney.id, max_round, false)
		puts "*****!!!!!!!*******!!!!!!! current_round_match_player_ids: #{current_round_match_player_ids.inspect}"
		players_unmatched = []
		tourney.players.each do |player|
		  if !current_round_match_player_ids.include? player.id
		    players_unmatched << player
		  end
		end
		puts "*****!!!!!!!*******!!!!!!! players_unmatched: #{players_unmatched.inspect}"

		# @entrants = players()
		# one round at a time, massage matches into the format for the view
		# for the most recent round, generate new pairings for unmatched entrants
		# need to check if the most recent round has results for all matches- if so, then generate pairings for the next round.
		TourneyService.remove_bye_matches tourney.id, max_round
		matches = []
		match_records = Match.where(tourney_id: tourney.id)
		match_records.each do |match|
		  match_with_names = match.dup
		  match_with_names.id = match.id
		  if Player.find_by(id: match.player1_id)
		    match_with_names.player1_name = Player.find_by(id: match.player1_id).name
		  end
		  puts "!!!!!!*********!!!!!!! in brackets, #{match.inspect}, #{match.player1_id}, #{Player.find_by(id: match.player1_id)}"
		  if Player.find_by(id: match.player2_id)
		    match_with_names.player2_name = Player.find_by(id: match.player2_id).name
		  end
		  matches << match_with_names if match.round.present? && match.round <= max_round
		end
		match_records = Match.where(tourney_id: tourney.id, round: max_round)
		if max_round == 0
		  pairs, bye_player = swiss_pairings_initial players_unmatched
		else
		  standings = generate_standings 
		  puts "*********!!!!!****** in tourney.brackets, players_unmatched: #{players_unmatched.inspect}"
		  standings_unmatched = standings.select {|standing| 
		    players_unmatched.include? standing[:player]
		  }
		  puts "*********!!!!!****** in tourney.brackets, standings_unmatched: #{standings_unmatched.inspect}"
		  good_enough_penalty = max_round * 0.1 #max_round * points_win * players_unmatched.count / 2
		  pairs, bye_player = generate_optimal_pairing standings_unmatched, good_enough_penalty, false
		  puts "*********!!!!!****** in tourney.brackets, bye_player: #{bye_player.inspect}"
		end
		if pairs.present?
		  player1, player2 = pairs.transpose
		  scores1, scores2, ties = [0] * pairs.length, [0] * pairs.length, [0] * pairs.length
		  round = [max_round] * pairs.length
		else
		  player1, player2 = nil, nil
		  scores1, scores2, ties = 0, 0, 0
		  round = max_round
		end
		if player1.present? && player2.present?
		  match_data = player1.zip(player2, scores1, scores2, ties, round)
		  match_data.each do |data|
		    parms = {tourney_id: tourney.id, player1_id: data[0][:id], player2_id: data[1][:id], player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5], bye: false}
		    match = Match.new parms
		    match.save
		    match_with_names = match.dup
		    match_with_names.id = match.id
		    puts "data[0]: #{data[0].inspect}"
		    puts "data[1]: #{data[1].inspect}"
		    match_with_names.player1_name = data[0][:name]
		    match_with_names.player2_name = data[1][:name]
		    matches << match_with_names
		  end
		end
		if bye_player
		  puts "*********!!!!!!!!!****** brackets, bye_player: #{bye_player.inspect}, #{bye_player.id}"
		  parms = {tourney_id: tourney.id, player1_id: bye_player.id, player2_id: bye_player.id, player1_score: 0, player2_score: 0, ties: 0, round: max_round, bye: true}
		  match = Match.new parms
		  match.save!
		  match_with_names = match.dup
		  match_with_names.id = match.id
		  puts "*******!!!!!!!! brackets, bye_player: #{bye_player.inspect}"
		  match_with_names.player1_name = match_with_names.player2_name = Player.find_by(id: bye_player.id).name
		  matches << match_with_names
		end

		return matches, bye_player
	end

  # GET /tourneys/1/brackets_initial
  def self.generate_brackets_initial
    players = Player.all()
    match_player_ids = Set.new
    match_records = Match.where(tourney: tourney.id).where("round <= 0")
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

  def generate_brackets_next good_enough_penalty
    # in response to user clicking on "generate next round".
    # if current round is complete, then proceed.
    # match up players by ranking according to standings
    # don't match up players who have played each other before
    # don't give a player two byes
    puts "******!!!!!!!!*********!!!!!!! in self.generate_brackets_next"
    players = tourney.players
    matches = []
    max_round = Match.where(tourney: tourney.id).maximum(:round)
    max_round = 0 if max_round.nil?
    current_round_match_player_ids = TourneyService.get_unique_complete_player_ids(tourney.id, max_round, true)
    puts "************** current_round_match_player_ids #{current_round_match_player_ids.inspect}"
    players_unmatched = []
    puts "************** Players: #{players.inspect}"
    players.each do |player|
      if !current_round_match_player_ids.include? player.id
        players_unmatched << player
      end
    end
    puts "************** players_unmatched #{players_unmatched}"
    if TourneyService.is_round_complete(tourney.id, max_round)
      standings_unmatched = tourney.generate_standings
      puts "**********************standings_unmatched: #{standings_unmatched}"
      puts "******!!!!!!!!!!!********!!!!!!!!!!!******** in self.generate_brackets_next, good_enough_penalty: #{good_enough_penalty}"
      pairs, bye_player = generate_optimal_pairing standings_unmatched, good_enough_penalty, false
      puts "******!!!!!!!!!!!********!!!!!!!!!!!******** in self.generate_brackets_next, bye_player: #{bye_player}"
    else
      return nil, nil
    end
    match_records = Match.where(tourney: tourney.id).order(:round)

    player1, player2 = pairs.transpose
    scores1, scores2, ties = [0] * pairs.length, [0] * pairs.length, [0] * pairs.length
    rounds = [max_round+1] * pairs.length
    if player1.present? && player2.present?
      match_data = player1.zip(player2, scores1, scores2, ties, rounds)
      match_data.each do |data|
        # puts "******!!!!!!******* data: #{data.inspect}"
        parms = {tourney_id: tourney.id, player1_id: data[0][:player_id], player2_id: data[1][:player_id], player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5], bye: false}
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
      parms = {tourney_id: tourney.id, player1_id: bye_player.id, player2_id: bye_player.id, player1_score: 0, player2_score: 0, ties: 0, round: max_round+1, bye: true}
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

end