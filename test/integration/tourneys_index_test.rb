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
    first_page_of_tourneys = Tourney.all
    first_page_of_tourneys.each do |tourney|
      assert_select 'a[href=?]', tourney_path(tourney), text: tourney.name
      unless user == @admin
        assert_select 'a[href=?]', tourney_path(tourney), text: 'delete',
                                                    method: :delete
      end
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
