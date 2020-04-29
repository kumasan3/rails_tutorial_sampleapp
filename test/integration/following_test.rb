require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other = users(:archer)
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

  test "should follow a user the standard way" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, params: {followed_id: @other.id } 
    end
    assert_redirected_to @other
  end

  test "should follow a user with Ajax" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, params: {followed_id: @other.id }, xhr: true 
    end
  end

  test "should unfollow an user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference "@user.following.count", -1 do
      delete relationship_path(relationship)
    end
    assert_redirected_to @other
  end

  test "should unfollow an user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    get user_path(@other)
    assert_select "div#follow_form>form>input.btn[value=?]", "Unfollow"
    assert_difference "@user.following.count", -1 do
      delete relationship_path(relationship), xhr: true
    end
    # get user_path(@other)
    # assert_select "div#follow_form>form>input.btn[value=?]", "Follow"
    
  end


  


end
