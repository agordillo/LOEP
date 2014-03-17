LOEP::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "registrations" }
  as :user do
    get 'signin' => 'home#frontpage', :as => :new_user_session
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  match '/los/remove' => 'los#removelist'
  match '/los/rankedIndex' => 'los#rankedIndex'
  match '/los/publicIndex' => 'los#publicIndex'
  match '/los/stats' => 'los#stats'
  match '/los/compare' => 'los#compare'
  match '/los/search' => 'los#searchIndex', via: [:get]
  match '/los/search' => 'los#search', via: [:post]
  match '/los/download' => 'los#download', via: [:get]
  match '/assignments/remove' => 'assignments#removelist'
  match '/automatic_assignments/new' => 'assignments#new_automatic', via: [:get]
  match '/automatic_assignments' => 'assignments#create_automatic', via: [:post]
  
  #EvMethods
  namespace :evaluations do
    resources :loris
  end

  resources :users
  resources :los
  resources :evaluations
  resources :evmethods
  resources :assignments
  resources :apps

  #Surveys
  match '/surveys/completed' => 'surveys#completed'
  namespace :surveys do
    resources :lorics
    resources :survey_ranking_as
  end

  root :to =>'home#frontpage'
  match '/home' => 'home#index'
  match '/tags' => 'application#serve_tags'

  match '/rlos/:id' => 'los#rshow'
  match '/rassignments' => 'assignments#rindex'
  match '/revaluations' => 'evaluations#rindex'
  match '/assignments/:id/complete' => 'assignments#complete'
  match '/assignments/:id/reject' => 'assignments#reject'

  #Web Services
  match '/surveys' => 'surveys#index'
  match '/generateToken' => 'application#generateToken'

  #LOEP API
  namespace :api do
    namespace :v1 do
      resources :los
    end
  end

  #Wildcard route
  match '*path' => 'application#page_not_found'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
