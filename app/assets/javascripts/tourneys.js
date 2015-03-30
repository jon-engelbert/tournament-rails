$(document).on ('ready page:load', function() {
  var entrantNames = $('#entrants').data('name');
  var entrantEmails = $('#entrants').data('email');
  $(document).on("ajax:success", "#Edit_scores", function() {
      console.log('file sent!');
    console.log('yep');
    });
  $('#tourney_entrant_names').val(entrantNames);
  $('#tourney_entrant_emails').val(entrantEmails);

  $( "#autocomplete-1" ).autocomplete({
     source: $('#players').data('name')
  });

  $( "#autocomplete-removeentrant" ).autocomplete({
     source: $('#entrants').data('name')
  });

  $("#addButton").click(function (e) {
    e.preventDefault();
    var name = $('#autocomplete-1').val();
    var position = $.inArray(name, $('#players').data('name'));
    // var hostAddress= top.location.host.toString();
    if (position >= 0) {
      // find the corresponding email, add it to the list.
      var players = $('#players').data('list');
      var email = players[position].email;
      $("#new_player").hide();
      $("#entrant_name_list").append('<li>' + name + '</li>');
      $("#entrant_email_list").append('<li>' + email + '</li>');
      var player_name_array = $('#players').data('name');
      var player_email_array = $('#players').data('email');
      player_email_array.splice(position,1)
      player_name_array.splice(position,1)
      $('#players').data('name', player_name_array);
      $('#players').data('email', player_email_array);
      $("#autocomplete-1").autocomplete( "option", "source", $('#players').data('name'));
      entrantNames.push(name);
      entrantEmails.push(email);
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
      $("#entrant_name_list").append('<li>' + name + '</li>');
      $("#entrant_email_list").append('<li>' + email + '</li>');
    entrantNames += name + "\r\n";
    // entrantEmails += email + "\r\n";
    $("#tourney_entrant_names").val(entrantNames) ;
    // $("#tourney_entrant_emails").val(entrantEmails) ;
    $("#new_player").hide();
    $('#entrants').data('name').add(selectedVal);
    $('#entrants').data('email').add(email);
  });
  $("#cancel_button").click(function (e) {
    e.preventDefault();
    $("#new_player").hide();
  });
    $("#removeButton").click(function (e) {
    e.preventDefault();
    var name = $('#autocomplete-removeentrant').val();
    var position = $.inArray(name, $('#entrants').data('name'));
    // var hostAddress= top.location.host.toString();
    if (position >= 0) {
      // find the corresponding email, remove it from the list.
      var email = $('#entrants').data('email')[position];
      var players = $('#players').data('list');
      var player_name_array = $('#players').data('name');
      var player_email_array = $('#players').data('email');
      player_email_array.push(email)
      player_name_array.push(name)
      $('#players').data('name', player_name_array);
      $('#players').data('email', player_email_array);
      $("#autocomplete-1").autocomplete( "option", "source", player_name_array);
 
      entrantNames.splice(position,1)
      entrantEmails.splice(position,1)
      $('#entrants').data('name', entrantNames);
      $('#entrants').data('email', entrantEmails);
      $('#tourney_entrant_names').val(entrantNames);
      $('#tourney_entrant_emails').val(entrantEmails);
      $("#autocomplete-removeentrants").autocomplete( "option", "source", entrantNames);
      $("#entrant_name_list li").eq(position).remove();
      $("#entrant_email_list li").eq(position).remove();
    }
  });

});
