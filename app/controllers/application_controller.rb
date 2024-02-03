class ApplicationController < ActionController::Base
  before_action :set_current_user


  def set_current_user
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    end
  end

  # ログインしてない場合のアクセス制限
  def autheniticate_user
    if @current_user == nil
      flash[:notice] = "ログインが必要です"
      redirect_to login_ideas_path
    end
  end


end
