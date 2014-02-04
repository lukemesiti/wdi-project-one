class SessionController < ApplicationController
    skip_before_action :authenticate

    def new
    end

    def create
        user = User.find_by_name(params[:username])
        if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect_to user_tasks_path(user.id), :notice => "you're now logged in"
        else
            redirect_to new_session_path, :notice => 'login incorrect'
        end
    end
    
    def destroy
        session[:user_id] = nil
        redirect_to new_session_path
    end



end
