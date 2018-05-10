require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  def setup
    @steve = users(:steve)
    @mark = users(:mark)

    @kitchen = rooms(:kitchen)
    @kitchen.user = @steve
  end

  test "#owned_by? should identify correct owner." do
    assert @kitchen.owned_by?(@steve)
  end

  test "#owned_by? should identify incorrect owner." do
    assert_not @kitchen.owned_by?(@mark)
  end
end
