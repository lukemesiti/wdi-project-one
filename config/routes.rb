Threethrees::Application.routes.draw do

  resources :users do
    resources :tasks, shallow: true do 
      resources :notes, shallow: true
    end
  end
  
  get '/login' => "session#new", :as => :new_session
  post '/login' => "session#create"
  
  delete '/logout' => "session#destroy", :as => :session

  get "pages/about_us"
  get "pages/contact_us"
  get "pages/references"

  root 'tasks#index'

end
