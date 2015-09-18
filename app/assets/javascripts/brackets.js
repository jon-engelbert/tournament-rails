$(document).on ('ready page:load', function() {
  // loop through all the matches on page, create data structures to hold them.
  // var Player = function (name, id) {
  //   this.name = name;
  //   this.id = id;
  //   this.wins = 0;
  // };

  var Match = function() {
    this.player1_name = '';
    this.player2_name = '';
    this.ties = 0;
    this.player1_wins = 0;
    this.player2_wins = 0;
    this.bye = false;
    this.SwapPlayer = function(player1_in, player2_in) {
      if (this.player1_name === player1_in)
        this.player1_name = player2_in;
      else if (this.player1_name === player2_in)
        this.player1_name = player1_in;
      else if (this.player2_name === player1_in)
        this.player2_name = player2_in;
      else if (this.player2_name === player2_in)
        this.player2_name = player1_in;
      else
        console.log("Error in Match.SwapPlayer");
    };
  };

  var Round = function() {
    this.matches = [];
    number = -1;
    this.GetMatchByID = function(id) {
      var i = 0;
      while (i < this.matches.length) {
        var match = this.matches[i];
        if (Number(match.id) === id) 
          return match;
        i += 1;
      }
      return null;
    };
    this.ReplaceMatch = function(match_in) {
      var i = 0;
      while (i < this.matches.length) {
        var match = this.matches[i];
        if (Number(match.id) === match_in.id) 
          this.matches[i] = match_in;
        i += 1;
      }
    };
  };


  var rounds = [];
  var round = null;
  var round_els = [];
  if (document.querySelectorAll)
      round_els = document.querySelectorAll(".round");
  for (var i=0, max=round_els.length; i < max; i++) {
    var round_el = round_els[i];
    round = new Round();
    round.number = i;
    rounds[i] = round;
    var matchup_els = round_el.getElementsByClassName('matchup');
    for (var j=0, maxj=matchup_els.length; j < maxj; j++) {
      var matchup_el = matchup_els[j];
      var match = new Match;
      round.matches[round.matches.length] = match;
      var matchscore_el = matchup_el.getElementsByClassName('match-score');

      match.ties = matchscore_el[0].dataset.ties;
      match.id = matchscore_el[0].dataset.matchid;
      var player_els = matchup_el.getElementsByClassName('player');
      if (player_els.length> 0) {
        var player_el1 = player_els[0];
        match.player1_name = matchscore_el[0].dataset.player1name;
        match.player1_wins = matchscore_el[0].dataset.player1wins;
      }
      if (player_els.length> 1) {
        var player_el2 = player_els[1];
        match.player2_name = matchscore_el[0].dataset.player2name;
        match.player2_wins = matchscore_el[0].dataset.player2wins;
      }
    }
  }
  var swapmatch_path = $('#paths').data('swap');
  var recordmatch_path = $('#paths').data('record');
    
  $('.static-div').scroll(function() {
    $(this).scrollLeft(0);
  });
  $('.side-by-side').scroll(function() {
    $(this).scrollLeft(0);
  });
  $('.left-div').scroll(function() {
    $(this).scrollLeft(0);
  });
  $('.right-div').scroll(function() {
    $(this).scrollLeft(0);
  });
  $('.middle-div').scroll(function() {
    $(this).scrollLeft(0);
  });
	$('.editMatchButton').click(function(e) {
		e.preventDefault();
    var n_round = 0;
		// $("#Edit_scores").show();
    if ($(this).data('round') >= 0) 
      n_round = $(this).data('round');
    $('#round').val(n_round);
    var round = rounds[n_round];
    var match_id = $(this).data('matchid');
    var match = round.GetMatchByID(match_id);
    $('#player1_name').text(match.player1_name + " wins");
    $('#player2_name').text(match.player2_name + " wins");
    $('#player1_wins').val(match.player1_wins);
    $('#player2_wins').val(match.player2_wins);
    $('#ties').val(match.ties);
    $('#match_id').val(match_id);

    $('#Edit_scores').show({positionTo: '#round_matches'});    
		// $('#player1_name').text($(this).data('player1name') + " wins");
		// $('#player2_name').text($(this).data('player2name') + " wins");
		// $('#player1_wins').val($(this).data('player1wins'));
		// $('#player2_wins').val($(this).data('player2wins'));
  //   $('#ties').val($(this).data('ties'));
  //   $('#match_id').val($(this).data('matchid'));
      dialog.dialog( "open" );
      iHeight = 370;
    if ($("#Edit_scores").parent().height() < iHeight) {
        $("#Edit_scores").parent().width(300 + 50);
        $("#Edit_scores").parent().animate({ height: iHeight, width: '300px'}, 500);
    }
		// alert("id:"+this.id);
		// $('#match_params').show();
		// $('#score1').val
	});
  $('.cancelEdit').click(function(e) {
    e.preventDefault();
          dialog.dialog( "close" );
  });
  $('.closeEdit').click(function(e) {
          dialog.dialog( "close" );
  });
  $('.submitScores').click(function(e) {
    submitScores(e);
  });

  var dialog = $( "#Edit_scores" ).dialog({
      autoOpen: false,
      height: 325,
      width: 350,
      modal: true,
      title: "Edit Match Scores",
      close: function() {
        // form[ 0 ].reset();
        // allFields.removeClass( "ui-state-error" );
      }
    });

  function updateScores (data) {
    dialog.dialog( "close" );
    console.log(data);
    match_data = data;
    $("#score_" + match_data["id"]).text(match_data["player1_score"]+ " - " + match_data["player2_score"] + "  (" + match_data["ties"] + ")  -- click to edit");
    $("#score_" + match_data["id"]).data('player1wins', match_data["player1_score"]);
    $("#score_" + match_data["id"]).data('player2wins', match_data["player2_score"]);
    $("#score_" + match_data["id"]).data('ties', match_data["ties"]);
    console.log("#score_" + match["id"]);
    console.log(match["player1_score"]);
  }

  function failUpdateScores(data) {
    dialog.dialog( "close" );
    alert (data);
    return false;
  }

  function submitScores(e) {
    var match_id = $("#match_id").val();
    var score1 = $("#player1_wins").val();
    var score2 = $("#player2_wins").val();
    var tourney_id = $("#tourneyid").val();
    var round = $("#round").val();
    var ties = $("#ties").val();
    // $("#score_" + match_id).text(score1 + " - " + score2 + "  (" + ties + ")");
    e.preventDefault();
    // var promise = 
    $.ajax({
      type: "POST",
      url: recordmatch_path,
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      data: JSON.stringify({ player1_wins: score1, player2_wins: score2, ties: ties, match_id: match_id, tourney_id: tourney_id, round: round}),
      dataType: 'json',
      contentType: 'application/json',
      success: function (data) {updateScores(data);},
      failure: function (data) {failUpdateScores(data);}
    });
    // promise.done(updateScores(data));
    // promise.fail(failUpdateScores);
  }
  
	$("#Edit_scores").on("ajax:success", function (e, data, status, xhr) {
		var match_temp = JSON.parse(xhr.responseText);
    var match = GetMatchByID(match["match_id"]);
		$("#AJAX_Results").append(xhr.responseText);
		$("#score_" + match["match_id"]).val(match["player1_score"]+ " - " + match["player2_score"] + "  (" + match["ties"] + ")");
		$("#AJAX_Results").append("#score_" + match["player1_name"]+ "_" + match["player2_name"]);
		$("#Edit_scores").hide();
	});

	$("#Edit_scores").on("ajax:error", function(e, xhr, status, error) {
		$("#AJAX_Results").append ("<p>ERROR</p>");
		$("#Edit_scores").hide();
	});

  var player1_name = '';
  var player2_name = '';
  var match1_id = 0;
  var match2_id = 0;
  var round1 = 0, round2 = 0;
  var drag_id = '';
  var drop_id = '';
  var drag_pos;
  $( ".draggable" ).draggable({
    appendTo: "body",
    cursor: "move",
    helper: 'clone',
    drag: function( event, ui ) {
      player1_name = $(this).data('playername');  
      match1_id = $(this).data('matchid');  
      round1 = $(this).data('round');
      drag_id = this.id;
      drag_pos = $(this).position();
      console.log('player_name, match_id, path');
      console.log(player1_name);
      console.log(match1_id);
      console.log(swapmatch_path);
      console.log($('#paths').data('swap'));
    },
    revert : function(event, ui) {
    // on older version of jQuery use "draggable"
    // $(this).data("draggable")
    // on 2.x versions of jQuery use "ui-draggable"
    // $(this).data("ui-draggable")
      $(this).data("uiDraggable").originalPosition = {
          top : 0,
          left : 0
      };
      // return boolean
      return !event;
      // that evaluate like this:
      // return event !== false ? false : true;
    }
  });

  function dropPlayer (data) {
// var d = JSON.parse(data);
    if (data['success'] === false) {
      return false;
    }
    if (data['round'] > rounds.length)
      return false;
    var round = rounds[data['round']];
    var match1 = round.GetMatchByID(data['match1_id']);
    var match2 = round.GetMatchByID(data['match2_id']);
    var player1_name = data['player1_name'];
    var player2_name = data['player2_name'];
    match1.SwapPlayer(player1_name, player2_name);
    match2.SwapPlayer(player1_name, player2_name);
    round.ReplaceMatch(match1);
    round.ReplaceMatch(match2);

    console.log("success:" + JSON.stringify(data));
    console.log("field_drag_id:" + drag_id);
    console.log(player2_name);
    console.log("field_drop_id:" + drop_id);
    console.log(player1_name);
    $("#" + drag_id ).text(player2_name);
    $("#" + drag_id ).attr('playername', player2_name);
    $("#" + drop_id ).text(player1_name);
    $("#" + drop_id ).attr('playername', player1_name);
    $("#" + drag_id ).css({ "position": "relative", "top": 0, "left": 0 });
    return true;
  }
  function failDropPlayer (data) {
    alert (data);
    $("#" + drag_id ).css({ "position": "relative", "top": 0, "left": 0 });
    return false;
  }

  $( ".droppable" ).droppable({
    tolerance: "intersect",
    accept: ".draggable",
    activeClass: "ui-state-default",
    hoverClass: "ui-state-hover",
    drop: function( event, ui ) {
      var fields = this.id.split('_');  
      var player2_name = $(this).data('playername');  
      var match2_id = $(this).data('matchid');  
      round2 = $(this).data('round');
      drop_id = this.id;
      if (match1_id == match2_id) {
        alert ("Swapping players in a match is not allowed");
        return false;
      }
      console.log("round1, round2: " + round1 +", " + round2);
      if (round1 != round2) {
        alert ("Swapping players from one round to another is not allowed");
        return false;
      }
      // $( this )
      //     .addClass( "ui-state-highlight" )
      //     .find( "p" )
      //       .html( this.id );
      var promise = $.ajax({
        type: "POST",
        url: swapmatch_path,
        beforeSend: function(xhr) {
          xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        data: JSON.stringify({ player1_swap: player1_name, player2_swap: player2_name, match1_id: match1_id, match2_id: match2_id, round: round1 }),
        dataType: 'json',
        contentType: 'application/json'
      });
      promise.done(dropPlayer);
      promise.fail(failDropPlayer);
    }
  });
});
