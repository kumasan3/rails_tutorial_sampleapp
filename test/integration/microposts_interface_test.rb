require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    if @user.microposts.count >= 2
      assert_match "#{@user.microposts.count} microposts", response.body
    elsif @user.microposts.count == 1
      assert_match "#{@user.microposts.count} micropost", response.body
    end
    assert_no_difference 'Micropost.count' do
      post microposts_path params: {micropost: {content: ""}}
    end
    assert_no_difference 'Micropost.count' do
      post microposts_path params: {micropost: {content: "  "}}
    end
    assert_select "div#error_explanation"
    assert_select "a[href=?]", '/?page=2' 
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path params: {micropost: {content:content}}
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end
    another_user = users(:archer)
    get user_path(another_user)
    assert_select "a", text: "delete", count: 0
    another_user.microposts.paginate(page: 1).each do |post|
      content = post.content
      assert_match content.split().first, response.body
    end
    assert_no_difference "Micropost.count" do
      delete micropost_path(another_user.microposts.paginate(page: 1).first)
    end
  end
  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 micropost", response.body
  end
end
