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

  resources :background_jobs, only:[:index, :show, :destroy] do
    post :retry, on: :member
  end

  resources :item_sales_percentage_reports, only: [:index] do
    get :columns, on: :collection
  end

  resources :items, param: :code, only: [:index, :show]

  resources :suppliers,param: :code, only: [:index, :show]

  resources :item_types,param: :code, only: [:index, :show]

  resources :brands,param: :code, only: [:index, :show]

  resources :discounts, param: :code, only: [:index, :show, :create, :show, :update, :destroy] do
    post :refresh_active_promotion, on: :collection
    post :refresh_all_promotion, on: :collection
    post :refresh_promotion, on: :member
    get :columns, on: :collection
  end

  resources :sales, only:[] do
    get :transaction_report, on: :collection
  end

  # will be removed start
  get 'sales/today_report', to: 'sales#transaction_report'
  get 'item_sales/today_report', to: 'item_sales#transaction_report'
  # will be removed end

  resources :item_sales, only:[] do
    get :transaction_report, on: :collection
  end

end
