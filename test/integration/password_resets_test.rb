require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password reset" do
    get new_password_reset_path
    assert_template "password_resets/new"
    assert_select 'input[name=?]', 'password_reset[email]'
    #メールアドレスが無効
    post password_resets_path params: {password_reset: {email: ""}}
    assert_not flash.empty?
    assert_template "password_resets/new"
    post password_resets_path params: {password_reset: {email: "invalidddddd@nono.com"}}
    assert_not flash.empty?
    assert_template "password_resets/new"
    #メールアドレスが有効
    post password_resets_path params: {password_reset: {email: @user.email}}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    #パスワード再設定フォームのテスト
    user = assigns(:user) #reset_tokenが@userには入らないから
    assert_nil @user.reset_token #その証拠
    get edit_password_reset_path(user.reset_token, email: "")
    assert_not flash.empty?
    assert_redirected_to root_url
    user.toggle!(:activated) #activatedされていない人
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_not flash.empty?
    assert_redirected_to root_url
    user.toggle!(:activated)
    get edit_password_reset_path("wrong token", email: user.email)
    assert_not flash.empty?
    assert_redirected_to root_url
    get edit_password_reset_path(user.reset_token, email: user.email)#有効パターン
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]", user.email
    #無効なパスワード確認
    patch password_reset_path(user.reset_token),
      params: {email: user.email, user: { password: "wrongPass", password_confirmation: "password" }}
    assert_template "password_resets/edit"
    assert_select "div#error_explanation"
    patch password_reset_path(user.reset_token),
      params: {email: user.email, user: { password: "  ", password_confirmation: "  " }}
    assert_select "div#error_explanation"
    patch password_reset_path(user.reset_token),
      params: {email: user.email, user:{ password: "password", password_confirmation: "password" }}
    assert_not flash.empty?
    assert_redirected_to user
    user.reload
    assert_nil user.reset_digest
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
        params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    assert_redirected_to new_password_reset_url
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end

  # メールアドレスが無効
  # メールアドレスが有効
  # パスワード再設定フォームのテスト
  # メールアドレスが無効
  # 無効なユーザー
  # メールアドレスが有効で、トークンが無効
  # メールアドレスもトークンも有効
  # 無効なパスワードとパスワード確認
  # パスワードが空
  # 有効なパスワードとパスワード確認
  
end
