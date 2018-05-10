require 'test_helper'

class MeetingTest < ActiveSupport::TestCase

  def setup
    @steve = users(:steve)

    @kitchen = rooms(:kitchen)
    
    @breakfast = meetings(:breakfast)
    @breakfast.room = @kitchen
  end

  test "name should be present." do
    @breakfast.name = nil
    assert_not @breakfast.valid?
  end

  test "should set uid on creation." do
    @breakfast.send(:generate_meeting_id)
    assert @breakfast.uid
  end
end
