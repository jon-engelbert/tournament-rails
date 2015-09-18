Feature: Tourneys
  As a tourneys admin
  I want to view a list of tourney
  In order to manipulate individual tourneys

Background:
  Given following tourneys exist:
      | name       | location          | points_win    | date                    | points_bye  | points_tie | user_id     |
      | mtg 1      | jonny's house     | 3             | 2014/02/03 07:00:00 UTC | 3           | 1          | 99          |
      | mtg 2      | bobby's house     | 3             | 2015/05/15 05:00:00 UTC | 3           | 1          | 99          |

  Scenario: Show index of events
    And I am on the Tourneys page
    Then I should see "mtg 1"
    And I should see "jonny's house"
    And I should see "7:00"
    And I should see "bobby's house"
