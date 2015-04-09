class Tourney < ActiveRecord::Base
  has_many :matches
  has_many :entrants
  has_many :players, through: :entrants
  belongs_to :users
  attr_accessor :entrant_names, :entrant_emails

  def swiss_pairings_initial(players)
    mod = players.length % 2
    use_bye = ( mod!= 0)
    puts "players.length, mod, use_bye: #{players.length}, #{mod}, #{use_bye}"
    player_bye_id = nil
    if use_bye
      bye_player = players.sample
      puts "bye_player: #{bye_player.inspect}"
    end
    is_begin_pair = true
    pairs = []
    prev_player = nil
    players.shuffle.each do |player|
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

  def swiss_pairings players_standings
    # don't match up players who have played each other before
    puts "************** In swiss_pairings"
    use_bye = players_standings.length % 2 != 0
    player_bye_id = nil
    max_round = Match.where(tourney: id).maximum(:round)
    max_round = 0 if max_round.nil?
    players_nobye = players_standings.select {|player|
      player[:total_matches] >= max_round
    }
    if use_bye && players_nobye.present?
      player_bye = players_nobye.sample[0][:player]
    end
    is_begin_pair = true
    prev_player = nil, player = nil
    i = 0
    pairs = []
    matches = Match.where(tourney: id).select {|match| match.player1_score > 0 || match.player2_score > 0 || match.ties > 0}
    match_ups = Match.matchups matches
    remaining_players = []
    players_standings.each do |player_standing|
      remaining_players << player_standing[:player]
    end
    while remaining_players.present? do 
      player = remaining_players.first
      if (!use_bye || (player[0] != player_bye))
        if i % 2 == 0
          prev_player = player
          player_to_remove = player
          remaining_players.delete player_to_remove
        else
          # need to find a player near prevPlayer, such that there is not match with the two already in it.
          # While this function would pass the unit tests it would not work in a real swiss tournament system
          # because it does not ensure that players only match against the same opponent once per tournament.
          is_already_played = true
          next_player_index = 0
          while is_already_played && next_player_index < remaining_players.count do
            player = remaining_players[next_player_index]
            is_already_played = match_ups.include?([player[:id], prev_player[:id]]) || match_ups.include?([prev_player[:id], player[:id]])
            next_player_index += 1
          end
          pair = [player, prev_player]
          remaining_players.delete player
          pairs.append(pair)
        end
        i += 1
      end
    end
    return pairs, player_bye
  end

  def pairings_cost pairings, bye_player_hash, previous_matchups, max_round, player_count
    cost = 0
    pairings.each do |player1, player2|
      cost += ((player1[:pts_per_match] - player2[:pts_per_match]) / points_win) ** 2
      if previous_matchups.include?([player1[:player][:id], player2[:player][:id]]) || previous_matchups.include?([player2[:player][:id], player1[:player][:id]])
        cost += player_count
      end
    end
    puts "*******!!!!!!!! pairings_cost, bye_player_hash: #{cost}, #{bye_player_hash}"
    cost += (max_round - bye_player_hash[:total_matches]) * player_count * 2 if bye_player_hash.present?
    puts "*******!!!!!!!! pairings_cost, bye_player_hash: #{cost}, #{bye_player_hash}"
    return cost
  end

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


  def generate_optimal_pairing_exhaustive player_standings, good_enough_penalty
    puts "****!!!!!!!******!!!!!! in generate_optimal_pairing, player_standings count: #{player_standings.count}"
    max_round = Match.where(tourney: id).maximum(:round)
    max_round = 0 if max_round.nil?
    bye_player_hash = nil
    bye_player = nil
    player_pairs = []
    min_cost = player_standings.count ** 3 + 2
    min_cost_pairs = nil
    min_cost_bye_player = nil
    matches = Match.where(tourney: id).select {|match| match.player1_score > 0 || match.player2_score > 0 || match.ties > 0}
    previous_matchups = Match.matchups matches
#first, try the standings in linear order
      player_pairs, bye_player, bye_player_hash = generate_pairs_from_standings player_standings
      cost = pairings_cost(player_pairs, bye_player_hash, previous_matchups, max_round, player_standings.count)
      if cost == 0
        return player_pairs, bye_player
      elsif cost < good_enough_penalty
        return player_pairs, bye_player
      elsif (cost < min_cost)
          min_cost_pairs = player_pairs
          min_cost_bye_player = bye_player
          min_cost = cost
      end

    player_standings.permutation.each do |players|
      player_pairs, bye_player, bye_player_hash = generate_pairs_from_standings players
      cost = pairings_cost(player_pairs, bye_player_hash, previous_matchups, max_round, player_standings.count)
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
    return min_cost_pairs, min_cost_bye_player
  end

  def generate_standings 
    """ what about byes? """
    standings = []
    player_list = players

    player1records = []
    player_list.each do |player|
      playermatches = matches.select {|match| match.player1_id == player.id}
      playermatchesRev = matches.select {|match| match.player2_id == player.id && !match.bye}
      playermatchesRev.each do |match|
        match_rev = match.dup
        match_rev.player1_score = match.player2_score
        match_rev.player2_score = match.player1_score
        playermatches << match_rev
      end
      match_wins = playermatches.count {|match| match.player1_score > match.player2_score}
      match_losses = playermatches.count {|match| match.player1_score < match.player2_score}
      match_ties = playermatches.count {|match| (match.player1_score == match.player2_score) && (match.player1_score > 0 || match.ties > 0)}
      match_byes = playermatches.count {|match| match.bye}
      game_wins = playermatches.sum {|match| match.player1_score}
      game_losses = playermatches.sum {|match| match.player2_score}
      match_points = points_win*match_wins + points_tie*match_ties + points_bye* match_byes
      total_matches = match_wins + match_losses + match_ties
      pts_per_match = total_matches == 0 ? 0 : (points_win*match_wins + points_tie*match_ties) / (1.0 * points_win * total_matches)
      puts "******!!!!!!!*******!!!!! player: #{player.inspect}"
      standing = {player_id: player.id, name: player.name, wins: match_wins, losses: match_losses, ties: match_ties, total_matches: total_matches, points: match_points, pts_per_match: pts_per_match, game_wins: game_wins, game_losses: game_losses, player: player}
      standings << standing
    end
    player_standings = standings.sort_by{|a| [a[:pts_per_match], a[:game_wins]]}.reverse
    puts "*******!!!!!!******* player_standings: #{player_standings}"
    player_standings
    # player1matches = matches   #.select("Player.id as player_id, player.name as name, match.player1_score as wins, match.player2_score as losses, match.ties as ties").order(name: :desc)
    # puts "player1s.inspect #{player1s.inspect}"
    # player2s = Player.select("player.id as player_id, player.name as name, matches.player2_score as wins, matches.player1_score as losses, matches.ties as ties").joins("LEFT OUTER JOIN matches ON player_id= matches.player2_id").order(name: :desc)
    # players = player1s.union(player2s)
    # @player_standings = players.select("player_id as id, name, count(case when wins > losses then 1 end) as match_wins, count(case when wins < losses then 1 end) as match_losses, count(case when wins = losses then 1 end) as match_ties, sum(wins) as game_wins, sum(losses) as game_losses, sum(ties) as game_ties").group_by(:player_id, :name).order(:match_wins)
  end

  def brackets 
    puts "************** In brackets"
    # players = Player.all()
    match_player_ids = Set.new
    match_records = Match.where(tourney_id: id)
    match_records.each do |match|
      match_player_ids << match.player1_id
      match_player_ids << match.player2_id
    end
    max_round = Match.where(tourney_id: id).maximum(:round)
    max_round = 0 if max_round.nil?
    current_round_match_player_ids = TourneyService.get_unique_complete_player_ids(id, max_round, false)
    puts "*****!!!!!!!*******!!!!!!! current_round_match_player_ids: #{current_round_match_player_ids.inspect}"
    players_unmatched = []
    puts "*****!!!!!!!*******!!!!!!! players: #{players.inspect}"
    puts "*****!!!!!!!*******!!!!!!! entrants: #{entrants.inspect}"
    players.each do |player|
      if !current_round_match_player_ids.include? player.id
        players_unmatched << player
      end
    end
    puts "*****!!!!!!!*******!!!!!!! players_unmatched: #{players_unmatched.inspect}"

    # @entrants = players()
    # one round at a time, massage matches into the format for the view
    # for the most recent round, generate new pairings for unmatched entrants
    # need to check if the most recent round has results for all matches- if so, then generate pairings for the next round.
    TourneyService.remove_bye_matches id, max_round
    matches = []
    match_records = Match.where(tourney_id: id)
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
    match_records = Match.where(tourney_id: id, round: max_round)
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
      pairs, bye_player = generate_optimal_pairing_exhaustive standings_unmatched, good_enough_penalty
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
        parms = {tourney_id: id, player1_id: data[0][:id], player2_id: data[1][:id], player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5], bye: false}
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
      parms = {tourney_id: id, player1_id: bye_player.id, player2_id: bye_player.id, player1_score: 0, player2_score: 0, ties: 0, round: max_round, bye: true}
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
end
