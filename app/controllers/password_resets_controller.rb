class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
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
end
