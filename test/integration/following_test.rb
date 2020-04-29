require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_select "strong#following", text: @user.following.count.to_s
    assert_select "strong#followers", text: @user.followers.count.to_s
    @user.following.each do |user| 
      assert_select "a[href=?]", user_path(user), 3
    end
  end

  test "follower page" do
    get followers_user_path(@user)
    assert_select "strong#following", text: @user.following.count.to_s
    assert_select "strong#followers", text: @user.followers.count.to_s
    @user.followers.each do |user| 
      assert_select "a[href=?]", user_path(user), 3
    end
  end
  


end
