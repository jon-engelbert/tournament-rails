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
      # puts "bye_player: #{bye_player}"
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
    puts "************** In swiss_pairings"
    use_bye = players_standings.length % 2 != 0
    player_bye_id = nil
    max_round = Match.where(tourney: id).maximum(:round)
    max_round = 0 if max_round.nil?
    players_nobye = players_standings.select {|player|
      puts "*************** player #{player.inspect}"
      puts "*************** max_round #{max_round}"
      player[:total_matches] >= max_round
    }
    if use_bye && players_nobye.present?
      player_bye = players_nobye.sample[0]
    end
    is_begin_pair = true
    prev_player = nil, player = nil
    i = 0
    pairs = []
    matches = Match.where(tourney: id).select {|match| match.player1_score > 0 || match.player2_score > 0 || match.ties > 0}
    match_p1 = matches.map(&:player1_id)
    match_p2 = matches.map(&:player2_id)
    match_ups = []
    if match_p1.present? 
      match_ups = match_p1.zip(match_p2)
    end
    puts "*********************** match_ups #{match_ups}"
    remaining_players = []
    players_standings.each do |player_standing|
      remaining_players << player_standing[:player]
    end
    while remaining_players.present? do 
      player = remaining_players.first
      if (!use_bye || (player[0] != player_bye))
        if i % 2 == 0
          puts "************************ i%2 == 0 player #{player.inspect}, #{player[:player].inspect}"
          prev_player = player
          player_to_remove = player
          puts "*********************** remaining players before delete: #{remaining_players.inspect}"
          remaining_players.delete player_to_remove
          puts "*********************** remaining players: #{remaining_players.inspect}"
        else
          puts "************************ player #{player.inspect}"
          puts "************************ prev_player #{prev_player.inspect}"
          # need to find a player near prevPlayer, such that there is not match with the two already in it.
          # While this function would pass the unit tests it would not work in a real swiss tournament system
          # because it does not ensure that players only match against the same opponent once per tournament.
          is_already_played = true
          next_player_index = 0
          while is_already_played && next_player_index < remaining_players.count do
            player = remaining_players[next_player_index]
            puts "************************ in loop, player #{player.inspect}"
            is_already_played = match_ups.include?([player[:id], prev_player[:id]]) || match_ups.include?([prev_player[:id], player[:id]])
            puts "*********************** match_ups #{match_ups}"
            puts "************************ is_already_played, player1, player2: #{is_already_played}, #{player[:id]}, #{prev_player[:id]}"
            next_player_index += 1
          end
          pair = [player, prev_player]
          puts "************************* pair: #{pair.inspect}"
          puts "*********************** remaining players before delete: #{remaining_players.inspect}"
          remaining_players.delete player
          puts "*********************** remaining players: #{remaining_players.inspect}"
          pairs.append(pair)
        end
        i += 1
      end
    end
    return pairs, player_bye
  end

  def generate_standings player_list
    """ what about byes? """
    standings = []

    player1records = []
    player_list.each do |player|
      puts "player #{player.inspect}"
      playermatches = matches.select {|match| match.player1_id == player.id}
      playermatchesRev = matches.select {|match| match.player2_id == player.id && !match.bye}
      playermatchesRev.each do |match|
        puts "**************** match #{match.inspect}"
        match_rev = match.dup
        match_rev.player1_score = match.player2_score
        match_rev.player2_score = match.player1_score
        playermatches << match_rev
        puts "match #{match.inspect}"
      end
      match_wins = playermatches.count {|match| match.player1_score > match.player2_score}
      match_losses = playermatches.count {|match| match.player1_score < match.player2_score}
      match_ties = playermatches.count {|match| match.player1_score == match.player2_score}
      match_byes = playermatches.count {|match| match.bye}
      match_points = 3*match_wins + match_ties + 3* match_byes
      total_games = match_wins + match_losses + match_ties
      win_pct = total_games == 0 ? 0 : (3.0*match_wins + match_ties) / total_games
      standing = {player_id: player.id, name: player.name, wins: match_wins, losses: match_losses, ties: match_ties, total_matches: total_games, points: match_points, win_pct: win_pct, player: player}
      puts "standing #{standing}"
      standings << standing
    end
    puts "*********************** standings: #{standings.inspect}"
    player_standings = standings.sort_by{|a| a[:win_pct]}.reverse
    puts "*********************** standings: #{player_standings.inspect}"
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
    puts "************** max_round: #{max_round}"
    current_round_match_player_ids = TourneyService.get_unique_complete_player_ids(id, max_round)
    entrants_unmatched = []
    puts "************** Players: #{players.inspect}"
    players.each do |entrant|
      if !current_round_match_player_ids.include? entrant.id
        entrants_unmatched << entrant
      end
    end
    puts "************** current_round_match_player_ids #{current_round_match_player_ids.inspect}"
    puts "************** entrants_unmatched #{entrants_unmatched}"

    # @entrants = players()
    # one round at a time, massage matches into the format for the view
    # for the most recent round, generate new pairings for unmatched entrants
    # need to check if the most recent round has results for all matches- if so, then generate pairings for the next round.
    TourneyService.remove_bye_matches id, max_round
    matches = []
    match_records = Match.where(tourney_id: id)
    match_records.each do |match|
      puts "******************* match: #{match.inspect}"
      match_with_names = match.dup
      match_with_names.id = match.id
      puts "******************* match_with_names: #{match_with_names.inspect}"
      match_with_names.player1_name = Player.find_by(id: match.player1_id).name
      match_with_names.player2_name = Player.find_by(id: match.player2_id).name
      matches << match_with_names if match.round.present? && match.round <= max_round
    end
    match_records = Match.where(tourney_id: id, round: max_round)
    if max_round == 0
      pairs, bye_player = swiss_pairings_initial entrants_unmatched
    else
      standings_unmatched = generate_standings entrants_unmatched
      puts "**********************standings_unmatched: #{standings_unmatched}"
      pairs, bye_player = swiss_pairings standings_unmatched
    end
    player1, player2 = pairs.transpose
    scores1, scores2, ties = [0] * pairs.length, [0] * pairs.length, [0] * pairs.length
    round = [max_round] * pairs.length
    if player1.present? && player2.present?
      match_data = player1.zip(player2, scores1, scores2, ties, round)
      match_data.each do |data|
        parms = {tourney_id: id, player1_id: data[0].id, player2_id: data[1].id, player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5], bye: false}
        match = Match.new parms
        match.save
        puts "******************* match: #{match.inspect}"
        match_with_names = match.dup
        match_with_names.id = match.id
        puts "******************* match_with_names: #{match_with_names.inspect}"
        match_with_names.player1_name = data[0].name
        match_with_names.player2_name = data[1].name
        matches << match_with_names
      end
    end
    if bye_player
      parms = {tourney_id: id, player1_id: bye_player.id, player2_id: bye_player.id, player1_score: 0, player2_score: 0, ties: 0, round: 0, bye: true}
      match = Match.new parms
      match.save!
      match_with_names = match.dup
      match_with_names.id = match.id
      match_with_names.player1_name = match_with_names.player2_name = Player.find_by(id: bye_player.id).name
      matches << match_with_names
    end

    # match_records.each do |match|
    #   matches.player1_name = Player.find_by(id: match.player1_id).name
    #   match.player2_name = Player.find_by(id: match.player2_id).name
    #   matches << match
    # end
    return matches, bye_player
    # puts "******************* match_count: #{@matches.count}"
    # puts "***************** @match_data: #{player1}"
    # puts "***************** scores1: #{scores1}"
    # puts "***************** matches: #{@matches.inspect}"
    # puts "***************** bye_player: #{@bye_player.inspect}"
    # puts "*****************  entrant player_names #{@player_names}"
    # puts "*****************  entrant player_emails #{@player_emails}"
    # puts "*****************   player_names #{@players.select("name").inspect}"
    # puts "***************** tourney id #{id}"
  end
end
