class UsersController < ApplicationController
  def new
    @user = User.new 
    #属性情報だけを持った@userを作成。属性情報を元に、form_withがフォーム作成
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)    # 実装は終わっていないことに注意!
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end