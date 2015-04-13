class RankManager
  attr_accessor :tourney

  def initialize(tour)
    self.tourney = tour
  end

  def get_player_matches this_player
    matches = Match.where(tourney_id: tourney.id)
    playermatches = matches.select {|match| match.player1_id == this_player.id}
    playermatchesRev = matches.select {|match| match.player2_id == this_player.id && !match.bye}
    playermatchesRev.each do |match|
      match_rev = match.dup
      match_rev.player1_score = match.player2_score
      match_rev.player2_score = match.player1_score
      match_rev.player1_id = match.player2_id
      match_rev.player2_id = match.player1_id
      playermatches << match_rev
    end
    return playermatches
  end

  def player_match_points this_player
    player_matches = get_player_matches this_player
    match_wins = player_matches.count {|match| match.player1_score > match.player2_score}
    match_losses = player_matches.count {|match| match.player1_score < match.player2_score}
    match_ties = player_matches.count {|match| (match.player1_score == match.player2_score) && (match.player1_score > 0 || match.ties > 0)}
    match_byes = player_matches.count {|match| match.bye}
    match_points = (match_wins * tourney.points_win + match_byes * tourney.points_bye + match_ties + tourney.points_tie)
  end

  def player_game_points this_player
    player_matches = get_player_matches this_player
    game_wins = player_matches.sum {|match| match.player1_score}
    game_losses = player_matches.sum {|match| match.player2_score}
    game_ties = player_matches.count {|match| (match.player1_score == match.player2_score) && (match.player1_score > 0 || match.ties > 0)}
    game_byes = player_matches.count {|match| match.bye} * 2
    puts "game_wins: #{game_wins}, game_byes: #{game_byes}, game_ties: #{game_ties}"
    game_points = (game_wins * tourney.points_win + game_byes * tourney.points_bye + game_ties * tourney.points_tie)
  end

  def player_game_total this_player
    game_total = 0
    player_matches = get_player_matches this_player
    game_total += player_matches.sum {|match| match.player1_score + match.player2_score + match.ties}
    game_total += player_matches.count {|match| match.bye} * 2
  end

  def player_match_pct this_player
    player_matches = get_player_matches this_player
    match_win_pct = (player_matches.count * tourney.points_win == 0) ? 0: player_match_points(this_player) / (1.0 * player_matches.count * tourney.points_win)
  end

  def player_game_pct this_player
    player_matches = get_player_matches this_player
    game_win_pct = (player_game_total(this_player) * tourney.points_win == 0) ? 0: player_game_points(this_player) / (1.0 * player_game_total(this_player) * tourney.points_win)
  end

  def opponents_match_pct this_player
    bye_count = 0
    other_match_pct_sum = 0.0
    player_matches = get_player_matches this_player
    player_matches.each do |match|
      if (!match.bye)
        other_player = Player.find(match.player2_id)
        other_match_pct = player_match_pct other_player
        other_match_pct_sum += other_match_pct
      else
        bye_count += 1
      end
    end
    opponent_match_pct = (player_matches.count - bye_count) == 0 ? 0 : other_match_pct_sum / (player_matches.count - bye_count)
  end

  def opponents_game_pct this_player
    other_game_total = 0
    other_game_pct_sum = 0.0
    player_matches = get_player_matches this_player
    player_matches.each do |match|
      if (!match.bye)
        other_player = Player.find(match.player2_id)
        other_game_pct = player_game_pct other_player
        other_game_pct_sum += other_game_pct
        other_game_total += player_game_total other_player
      end
    end
    opponent_game_pct = (other_game_total) == 0 ? 0 : other_game_pct_sum / (other_game_total)
  end

  def generate_standings 
    standings = []
    player_list = tourney.players
    player1records = []
    player_list.each do |player|
      playermatches = get_player_matches player
      match_wins = playermatches.count {|match| match.player1_score > match.player2_score}
      match_losses = playermatches.count {|match| match.player1_score < match.player2_score}
      match_ties = playermatches.count {|match| (match.player1_score == match.player2_score) && (match.player1_score > 0 || match.ties > 0)}
      match_byes = playermatches.count {|match| match.bye}
      game_wins = playermatches.sum {|match| match.player1_score}
      game_losses = playermatches.sum {|match| match.player2_score}
      match_points = tourney.points_win * match_wins + tourney.points_tie*match_ties + tourney.points_bye* match_byes
      total_matches = match_wins + match_losses + match_ties + match_byes
      pts_per_match = total_matches == 0 ? 0 : (match_points) / (1.0 * tourney.points_win * total_matches)
      puts "******!!!!!!!*******!!!!! player: #{player.inspect}"
      puts "******!!!!!!!*******!!!!! game_pct: #{player_game_pct(player)}}"
      standing = {player_id: player.id, name: player.name, wins: match_wins, losses: match_losses, ties: match_ties, total_matches: total_matches, pts_per_match: pts_per_match, match_points: match_points, opponents_match_pct: opponents_match_pct(player), player_game_pct: player_game_pct(player), opponents_game_pct: opponents_game_pct(player), player: player}
      standings << standing
    end
    player_standings = standings.sort_by{|a| [a[:match_points], a[:opponents_match_pct], a[:player_game_pct], a[:opponents_game_pct]]}.reverse
    puts "*******!!!!!!******* player_standings: #{player_standings}"
    player_standings
  end

end
