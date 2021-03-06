Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  get 'password_resets/new'

  get 'password_resets/edit'

  root                'static_pages#home'
  get    'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  post   'connect_google'   => 'sessions#google_connect'
  get 'login_google' => 'sessions#login_oauth'
  get 'login_oauth' => 'sessions#login_oauth'
  get 'login_facebook' => 'sessions#login_oauth'
  get '/auth/:provider/callback', to: 'sessions#create_oauth'
  get '/auth/failure', to: 'sessions#auth_failure'
  # get    'login_google'   => 'sessions#login_google'
  # post   'login_google'   => 'sessions#create_google'
  # get    'login_facebook'   => 'sessions#login_facebook'
  # post   'login_facebook'   => 'sessions#create_facebook'
  delete 'logout'  => 'sessions#destroy'

  resources :matches do
    member do
      post 'record'
    end
    collection do
      post 'swap'
    end
  end

  resources :tourneys
  resources :tourneys do
    member do
      get 'brackets'
      get 'brackets_next'
      get 'standings'
    end
  end

  resources :users

  resources :players
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

# The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :user do
  #     # Directs /user/products/* to User::ProductsController
  #     # (app/controllers/user/products_controller.rb)
  #     resources :products
  #   end
end
