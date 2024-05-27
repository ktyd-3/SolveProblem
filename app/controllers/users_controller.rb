class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
        session[:user_id] = @user.id
        flash[:notice] = "アカウントの作成に成功"
        redirect_to themes_ideas_path
    else
      flash.now[:error]
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "ログアウトしました"
    redirect_to root_path
  end

  private

  def user_params
      params.require(:user).permit(:user_name, :email, :password)
  end

end
