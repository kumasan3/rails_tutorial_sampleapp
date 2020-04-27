class PasswordResetsController < ApplicationController
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
end
