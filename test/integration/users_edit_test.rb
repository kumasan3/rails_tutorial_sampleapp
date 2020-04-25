require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'unsuccesful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
      email: "foo@invalid",
      password:              "foo",
      password_confirmation: "bar" } }
      assert_template 'users/edit'
      assert_select 'div.alert-danger'
      assert_select 'div.alert-danger', :text => "The form contains 4 errors."
  end
  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:"",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
      email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do 
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do 
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
      email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "succesful edit when friendly fowarding" do
    get edit_user_path(@user) #ログインしてないのにeditURLにアクセス
    assert_redirected_to login_url #だからログインURLに飛ぶ
    log_in_as(@user) #ここでログイン
    assert_redirected_to edit_user_url(@user) #その後はeditURLに飛ぶこと
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:"",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test "friendly forwarding direct works only one time" do
    get edit_user_path(@user) #ログインしてないのにeditURLにアクセス
    assert_redirected_to login_url #だからログインURLに飛ぶ
    assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user) #ここでログイン
    assert_redirected_to edit_user_url(@user) #その後はeditURLに飛ぶこと
    delete logout_path
    assert_redirected_to root_url
    log_in_as(@user) #再度ログイン
    assert_redirected_to @user #2回目はプロフィールに飛ぶ
    assert_equal session[:forwarding_url], nil
  end
end
