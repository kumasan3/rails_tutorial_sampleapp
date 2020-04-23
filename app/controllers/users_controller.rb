class UsersController < ApplicationController
  def new
    @user = User.new  #属性情報だけを持った@userを作成。属性情報を元に、form_withがフォーム作成
  end

  def show
    @user = User.find(params[:id])
  end
end
