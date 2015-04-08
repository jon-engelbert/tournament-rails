require 'test_helper'

class TourneysIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @t1 = tourneys("mtg1")
    @t2 = tourneys("mtg2")
  end

  test "tourney as admin" do
    log_in_as(@admin)
    get tourneys_path
    assert_template 'tourneys/index'
    tourney_page = Tourney.all
    # assert_select 'a[href=?]', tourney_path(tourney_page), text: 'Show'
    unless current_user == @admin
      assert_select 'a[href=?]', tourney_path(tourney_page), text: 'Delete',
                                                  method: :delete
    end
    assert_difference 'Tourney.count', -1 do
      delete tourney_path(@t1)
    end
  end

  test "tourney index as non-admin" do
    log_in_as(@non_admin)
    get tourneys_path
    assert_select 'a', text: 'delete', count: 0
  end
end
