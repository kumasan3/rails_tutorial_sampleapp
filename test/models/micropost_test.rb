require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "testcontent")
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "should be invalid" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content  = "  "
    assert_not @micropost.valid?
  end

  test "contetn should be less than 140 characters" do
    @micropost.content =  "a" * 141
    assert_not @micropost.valid?
  end

  test "contetn should be less than 140 characters #2" do
    @micropost.content =  "a" * 140
    assert @micropost.valid?
  end

  test "order should be the most recent file" do
    # assert_equal Micropost.first, "okpo"
    assert_equal microposts(:most_recent), Micropost.first
  end


end
