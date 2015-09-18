#Tournament Brackets Manager
This application allows the signed in user to set up a swiss-style tournament with a set of entrants, then to generate brackets, enter match results, and generate new round brackets until the tournament is over.
The standings can also be viewed.

Presently, the signup step is broken, i.e. the 'mailer' doesn't actually send an email out to you as the new registered user, so even if you sign up you won't be able log in yet.  I'm going to work to fix that soon.  Also, If I have time, I'll seed it with some data so that it's more interesting.


*The heroku instance is at: https://turnkey-tourney.herokuapp.com/*

*To build & run it locally:*
*cd into the project folder.*
*bundle install*
*rake db:migrate*
*rake db:seed*
*rails s*

