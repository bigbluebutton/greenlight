require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should create user from omniauth" do
    uid = '354545'
    provider = 'twitter'
    name = 'user name'
    username = 'username'

    assert_difference 'User.count' do
      User.from_omniauth({'uid' => uid, 'provider' => provider, 'info' => {'name' => name, 'nickname' => username}})
    end

    user = User.find_by uid: uid, provider: provider
    assert_not_nil user.encrypted_id
    assert user.username, username
    assert user.name, name
  end
end
