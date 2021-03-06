class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  def new
  end
  def create # reset_tokenの作成
    @user = User.find_by(email: params[:password_reset][:email])

    if @user
      @user.create_reset_digest #ダイジェストをDBに保存
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "address not found"
      render "new"
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render "edit"
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      @user.update_attribute(:reset_digest, nil)
      redirect_to @user
    else
      render "edit"
    end
  end

  private

    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user #reset_tokenは resources のルーティングに従い、params[:id]に入る
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url #false ならroot_urlにリダイレクト
      end
      #trueなら、何もしない。 editアクションなら "edit"テンプレートが呼ばれる
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired"
        redirect_to new_password_reset_url
      end
    end
end
