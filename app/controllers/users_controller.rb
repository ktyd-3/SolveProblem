class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
        session[:user_id] = @user.id
        flash[:success] = "アカウントを作成しました。"
        redirect_to root_path
    else
        render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "ログアウトしました。"
  end

  private

  def user_params
      params.require(:user).permit(:user_name, :email, :password, :password_confirmation)
  end

end
