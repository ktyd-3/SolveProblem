class SessionsController < ApplicationController

  def destroy
    session[:user_id] = nil
    flash[:success] = "ログアウトしました。"
    redirect_to root_path
  end

  def new

  end

  def create
    user = User.find_by(email: params[:email])
      if user.present? && user.authenticate(params[:password])
          session[:user_id] = user.id
          flash[:notice] = "ログインしました"
          redirect_to themes_ideas_path
      else
          flash[:error] = "ログインに失敗しました。もう一度試してください"
          redirect_to login_ideas_path
      end
  end

end
