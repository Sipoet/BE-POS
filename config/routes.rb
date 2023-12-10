Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#dashboard"
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout'
  },
  controllers: {
    sessions: 'users/sessions'
  }
  resources :reports, only: [] do
    get :item_sales_percentage, on: :collection
  end

  resources :items, param: :code, only: [:index, :show]

  resources :suppliers,param: :code, only: [:index, :show]

  resources :item_types,param: :code, only: [:index, :show]

  resources :brands,param: :code, only: [:index, :show]

  resources :discounts, param: :code, only: [:index, :show, :create, :show, :update, :destroy] do
    post :refresh_item_promotion, on: :collection
  end

end
