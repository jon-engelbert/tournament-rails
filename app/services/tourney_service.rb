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


  def self.get_unique_complete_player_ids tourney_id, round, include_byes
    match_player_ids = Set.new
    match_records = Match.where(tourney: tourney_id, round: round, bye: false)
    match_records.each do |match|
      match_player_ids << match.player1_id
      match_player_ids << match.player2_id
    end
    if include_byes
      bye_match_record = Match.where(tourney: tourney_id, round: round, bye: true)
      puts "******!!!!!******** in get_unique_complete_player_ids, bye_match_record: #{bye_match_record}, #{bye_match_record[0].inspect}"
      match_player_ids << bye_match_record[0].player1_id if bye_match_record.present?
    end
    match_player_ids
  end

  def self.remove_bye_matches tourney_id, round
    Match.where(tourney: tourney_id, round: round, bye: true).destroy_all
  end



  # GET /standings
  # GET /standings.json


end
