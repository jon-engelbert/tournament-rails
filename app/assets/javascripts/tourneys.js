$(document).on ('ready page:load', function() {
  var entrantNames = $('#entrants').data('name');
  var entrantEmails = $('#entrants').data('email');
  $('#tourney_entrant_names').val(entrantNames);
  $('#tourney_entrant_emails').val(entrantEmails);

  $( "#autocomplete-1" ).autocomplete({
     source: $('#players').data('name')
  });

  $("#addButton").click(function (e) {
    e.preventDefault();
    var name = $('#autocomplete-1').val();
    var position = $.inArray(name, $('#players').data('name'));
    var hostAddress= top.location.host.toString();
    if (position >= 0) {
      // find the corresponding email, add it to the list.
      var players = $('#players').data('list');
      var email = players[position].email;
      $("#new_player").hide();
      entrantNames += name + "\r\n";
      entrantEmails += email + "\r\n";
      $('#tourney_entrant_names').val(entrantNames);
      $('#tourney_entrant_emails').val(entrantEmails);
    } else {
      // var url = "http://" + hostAddress + $('#newplayerlink').data('link');
      // $(location).attr('href',url);
      $("#new_player").show();
      $('#player_name').val(name);
      $('#player_email').val('');
    }
  });
  $("#create_button").click(function (e) {
    e.preventDefault();
    var name = $('#player_name').val();
    var email = $('#player_email').val();
    entrantNames += name + "\r\n";
    entrantEmails += email + "\r\n";
    $("#tourney_entrant_names").val(entrantNames) ;
    $("#tourney_entrant_emails").val(entrantEmails) ;
    $("#new_player").hide();
    $('#entrants').data('name').add(selectedVal);
    $('#entrants').data('email').add(email);
  });
  $("#cancel_button").click(function (e) {
    e.preventDefault();
    $("#new_player").hide();
  });
});
