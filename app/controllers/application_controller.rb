class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate

  def authenticate
    if session[:user_id]
      @current_user = User.find(session[:user_id])
    else
      redirect_to new_session_path
    end
  end

  def logged_in?
    @current_user.present?
  end

  helper_method :logged_in?

end
