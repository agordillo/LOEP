LOEP::Application.routes.draw do

  #Users
  devise_for :users, :controllers => { :registrations => "registrations" }
  as :user do
    get 'signin' => 'home#frontpage', :as => :new_user_session
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  resources :users
  
  match '/icodes/:id/invitation' => 'icodes#send_invitation_mail', via: [:post]
  resources :icodes, :except => [:index, :update]

  #Root page
  root :to =>'home#frontpage'
  match '/home' => 'home#index'

  #Learning Objects
  match '/los/remove' => 'los#removelist'
  match '/los/rankedIndex' => 'los#rankedIndex'
  match '/los/publicIndex' => 'los#publicIndex'
  match '/los/stats' => 'los#stats'
  match '/los/compare' => 'los#compare'
  match '/los/search' => 'los#searchIndex', via: [:get]
  match '/los/search' => 'los#search', via: [:post]
  match '/los/download' => 'los#download', via: [:get]
  match '/los/downloadevs' => 'los#downloadevs', via: [:get]
  match '/los/:id/representation' => 'los#showEvaluationsRepresentation', via: [:get]
  match '/rlos/:id' => 'los#rshow'
  resources :los

  #Assignments
  match '/rassignments' => 'assignments#rindex'
  match '/assignments/:id/complete' => 'assignments#complete'
  match '/assignments/:id/reject' => 'assignments#reject'
  match '/assignments/remove' => 'assignments#removelist'
  match '/automatic_assignments/new' => 'assignments#new_automatic', via: [:get]
  match '/automatic_assignments' => 'assignments#create_automatic', via: [:post]
  resources :assignments

  #EvMethods and Evaluations
  #EvMethods
  match '/evmethods/:id/documentation' => 'evmethods#documentation'
  match '/evmethods/:id/representation' => 'evmethods#representation'
  resources :evmethods

  #Evaluations
  match '/revaluations' => 'evaluations#rindex'
  namespace :evaluations do
    resources :loems, :loris, :wbltses, :wbltts do
      get 'embed', :on => :collection
      get 'print', :on => :collection
    end
  end
  resources :evaluations
  
  #Applications
  devise_for :apps
  match '/apps/:id/create_session_token' => 'apps#create_session_token', via: [:get, :post]
  resources :apps
  
  #Surveys
  match '/surveys/completed' => 'surveys#completed'
  namespace :surveys do
    resources :lorics
    resources :survey_ranking_as
  end

  #Contact
  match '/contact' => 'contact#new', via: [:get]
  match '/contact_send' => 'contact#send_mail', via: [:post]

  #Web Services
  match '/tags' => 'application#serve_tags'
  match '/surveys' => 'surveys#index'
  match '/generateToken' => 'application#generateToken'

  #LOEP API
  namespace :api do
    namespace :v1 do
      match '/tokens' => 'tokens#destroy_my_token', :via => :delete, :format => :json
      resources :tokens,:only => [:create, :destroy]
      match '/app_tokens' => 'app_tokens#destroy_my_token', :via => :delete, :format => :json
      resources :app_tokens,:only => [:create, :destroy]
      match '/session_token/current' => 'session_token#current'
      resources :session_token

      resources :los
    end
  end

  #Special pages used for research
  match '/custom' => 'customSearch#index'
  match '/slidesetsstats' => 'application#slidesetsstats', via: [:get]

  #Wildcard route (This rule should be placed the last)
  match '*path' => 'application#page_not_found'
end
