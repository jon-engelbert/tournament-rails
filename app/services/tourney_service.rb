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
      puts "*************** is_incomplete 1 #{is_incomplete}"
    end
    entrants_unmatched = []
    tourney.players.each do |entrant|
      if !match_player_ids.include? entrant.id
        entrants_unmatched << entrant
        puts "entrants_unmatched: #{entrants_unmatched}"
      end
    end
    is_incomplete = !entrants_unmatched.empty?
      puts "*************** is_incomplete 2 #{is_incomplete}"
    matches.each do |match|
      is_incomplete ||= !match.bye && match.player1_score == 0 && match.player2_score == 0 && match.ties == 0
      puts "*************** is_incomplete 3 #{is_incomplete}"
    end
    !is_incomplete
  end


  def self.generate_brackets_next tourney_id
    # in response to user clicking on "generate next round".
    # if current round is complete, then proceed.
    # match up players by ranking according to standings
    # don't match up players who have played each other before
    # don't give a player two byes
    tourney = Tourney.find(tourney_id)
    players = Player.all()
    matches = []
    max_round = Match.where(tourney: tourney_id).maximum(:round)
    puts "***************** max_round #{max_round}"
    if is_round_complete(tourney_id, max_round)
      player_standings = generate_standings tourney_id
      pairs, bye_player = tourney.swiss_pairings player_standings
      puts "************ pairs: #{pairs.inspect}"
    else
      return nil, nil
    end
    match_records = Match.where(tourney: tourney_id).order(:round)

    player1, player2 = pairs.transpose
    puts "********************* #{player1.inspect}"
    puts "********************* #{player2.inspect}"
    scores1, scores2, ties = [0] * pairs.length, [0] * pairs.length, [0] * pairs.length
    rounds = [max_round+1] * pairs.length
    if player1.present? && player2.present?
      match_data = player1.zip(player2, scores1, scores2, ties, rounds)
      match_data.each do |data|
        parms = {tourney_id: tourney_id, player1_id: data[0].id, player2_id: data[1].id, player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5], bye: false}
        match = Match.new parms
        match.save
        match.player1_name = data[0].name
        match.player2_name = data[1].name
        matches << match
        puts "*********************** match #{match.inspect}"
      end
    end
    if bye_player
      parms = {tourney_id: tourney_id, player1_id: bye_player.id, player2_id: bye_player.id, player1_score: 0, player2_score: 0, ties: 0, round: max_round+1, bye: true}
      match = Match.new parms
      match.save
      matches << match
      puts "*********************** match #{match.inspect}"
    end

    match_records.each do |match|
      match.player1_name = Player.find_by(id: match.player1_id).name
      match.player2_name = Player.find_by(id: match.player2_id).name
      matches << match
      puts "*********************** match #{match.inspect}"
    end
    puts "********************** END of generate_next_round"
    return matches, bye_player
  end

  def self.get_unique_complete_player_ids tourney_id, round
    match_player_ids = Set.new
    match_records = Match.where(tourney: tourney_id, round: round, bye: false)
    match_records.each do |match|
      match_player_ids << match.player1_id
      match_player_ids << match.player2_id
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
        parms = {tourney_id: tourney_id, player1_id: data[0].id, player2_id: data[1].id, player1_score: data[2], player2_score: data[3], ties: data[4], round: data[5]}
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
    # puts "******************* match_count: #{@matches.count}"
    # puts "***************** @match_data: #{player1}"
    # puts "***************** scores1: #{scores1}"
    # puts "***************** matches: #{@matches.inspect}"
    # puts "***************** bye_player: #{@bye_player.inspect}"
    # puts "*****************  entrant player_names #{@player_names}"
    # puts "*****************  entrant player_emails #{@player_emails}"
    # puts "*****************   player_names #{@players.select("name").inspect}"
    # puts "***************** tourney id #{@tourney.id}"
  end

  # GET /standings
  # GET /standings.json

  def self.generate_standings tourney_id
    """ what about byes? """
    matches = []
    standings = []
    tourney = Tourney.find(tourney_id)
    players = tourney.players

    matches = tourney.matches

    player1records = []
    players.each do |player|
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
      if total_games > 0
        win_pct = (3.0*match_wins + match_ties) / total_games
      else
        win_pct = 0
      end
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

end
