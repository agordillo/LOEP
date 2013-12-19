LOEP::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "registrations" }
  as :user do
    get 'signin' => 'home#frontpage', :as => :new_user_session
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  match '/los/remove' => 'los#removelist'
  match '/los/rankedIndex' => 'los#rankedIndex'
  match '/automatic_assignments/new' => 'assignments#new_automatic', via: [:get]
  match '/automatic_assignments' => 'assignments#create_automatic', via: [:post]
  
  resources :users
  resources :los
  resources :evaluations
  resources :lori_evaluations
  resources :evmethods
  resources :assignments
  resources :lorics

  root :to =>'home#frontpage'
  match '/home' => 'home#index'
  match '/tags' => 'application#serve_tags'

  match '/rlos/:id' => 'los#rshow'
  match '/rassignments' => 'assignments#rindex'
  match '/revaluations' => 'evaluations#rindex'
  match '/assignments/:id/reject' => 'assignments#reject'

  match '/surveys' => 'application#surveys'

  #LOEP API
  namespace :api do
    namespace :v1 do
      #/api/v1/addLo
      match '/addLo' => 'base#addLo', via: [:post]
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
