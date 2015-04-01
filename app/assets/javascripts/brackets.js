$(document).on ('ready page:load', function() {
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
		// $("#Edit_scores").show();
    $('#Edit_scores').show({positionTo: '#round_matches'});    
		$('#player1_name').text($(this).data('player1name') + " wins");
		$('#player2_name').text($(this).data('player2name') + " wins");
		$('#player1_wins').val($(this).data('player1wins'));
		$('#player2_wins').val($(this).data('player2wins'));
    $('#ties').val($(this).data('ties'));
    $('#match_id').val($(this).data('matchid'));
		if ($(this).data('round') < 0) {
			$('#round').val(0);
		} else {
			$('#round').val($(this).data('round'));
		}
      dialog.dialog( "open" );
      iHeight = 370;
    if ($("#Edit_scores").parent().height() < iHeight) {
        $("#Edit_scores").parent().width(300 + 50);
        $("#Edit_scores").parent().animate({ height: iHeight, width: '300px'}, 500);
    }
		// alert("id:"+this.id);
		// $('#match_params').show();
		// $('#score1').val
	})
  $('.cancelEdit').click(function(e) {
    e.preventDefault();
          dialog.dialog( "close" );
  })
  $('.closeEdit').click(function(e) {
          dialog.dialog( "close" );
  })
  $('.submitScores').click(function(e) {
    submitScores(e);
  })
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

  function submitScores(e) {
    var match_id = $("#match_id").val();
    var score1 = $("#player1_wins").val();
    var score2 = $("#player2_wins").val();
    var tourney_id = $("#tourneyid").val();
    var round = $("#round").val();
    var ties = $("#ties").val();
    // $("#score_" + match_id).text(score1 + " - " + score2 + "  (" + ties + ")");
    e.preventDefault();
    $.ajax({
      type: "POST",
      url: recordmatch_path,
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      data: JSON.stringify({ player1_wins: score1, player2_wins: score2, ties: ties, match_id: match_id, tourney_id: tourney_id, round: round}),
      dataType: 'json',
      contentType: 'application/json',
      success: function (data) {
        dialog.dialog( "close" );
        console.log(data);
        match = data;
        $("#score_" + match["id"]).text(match["player1_score"]+ " - " + match["player2_score"] + "  (" + match["ties"] + ")  -- click to edit");
        $("#score_" + match["id"]).data('player1wins', match["player1_score"]);
        $("#score_" + match["id"]).data('player2wins', match["player2_score"]);
        $("#score_" + match["id"]).data('ties', match["ties"]);
        console.log("#score_" + match["id"]);
        console.log(match["player1_score"]);
      },
      error: function (data) {
        dialog.dialog( "close" );
        alert (data);
        return false;
      }
    })

  }
  
	$("#Edit_scores").on("ajax:success", function (e, data, status, xhr) {
		var match = JSON.parse(xhr.responseText);
		$("#AJAX_Results").append(xhr.responseText);
		$("#score_" + match["match_id"]).val(match["player1_score"]+ " - " + match["player2_score"] + "  (" + match["ties"] + ")");
		$("#AJAX_Results").append("#score_" + match["player1_name"]+ "_" + match["player2_name"]);
		$("#Edit_scores").hide();
	})
	$("#Edit_scores").on("ajax:error", function(e, xhr, status, error) {
		$("#AJAX_Results").append ("<p>ERROR</p>");
		$("#Edit_scores").hide();
	})
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
      round1 = $(this).data('round')
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
      $.ajax({
        type: "POST",
        url: swapmatch_path,
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        data: JSON.stringify({ player1_swap: player1_name, player2_swap: player2_name, match1_id: match1_id, match2_id: match2_id }),
        dataType: 'json',
        contentType: 'application/json',
        success: function (data) {
		// var d = JSON.parse(data);
          if (data['success'] === false) {
          	return false;
          }
          console.log("success:" + data);
          console.log("field_drag_id:" + drag_id);
          console.log(player2_name);
          console.log("field_drop_id:" + drop_id);
          console.log(player1_name);
          $("#" + drag_id ).text(player2_name);
          $("#" + drag_id ).attr('playername', player2_name);
          $("#" + drop_id ).text(player1_name);
          $("#" + drop_id ).attr('playername', player1_name);
          $("#" + drag_id ).css({ "position": "relative", "top": 0, "left": 0 });
        },
        error: function (data) {
          alert (data);
          $("#" + drag_id ).css({ "position": "relative", "top": 0, "left": 0 });
          return false;
        }
      })
    }
  });
})
