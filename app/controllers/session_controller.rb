class SessionController < ApplicationController
    skip_before_action :authenticate

    def new
    end

    def create
        user = User.find_by_name(params[:username])
        if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect_to user_tasks_path(user.id)
        else
            redirect_to new_session_path, :alert => 'Login incorrect'
        end
    end
    
    def destroy
        session[:user_id] = nil
        redirect_to new_session_path
    end



end
