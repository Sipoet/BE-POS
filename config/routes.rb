Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#dashboard"
  get 'settings',to:'home#settings'
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout'
  },
  controllers: {
    sessions: 'users/sessions'
  }

  resources :users, param: :username, only: [:index, :show, :destroy, :update, :create]
  resources :background_jobs, only:[:index, :show, :destroy] do
    post :retry, on: :member
  end

  resources :item_sales_percentage_reports, only: [:index] do
    get :columns, on: :collection
    get :group_by_supplier, on: :collection
  end

  resources :items, param: :code, only: [:index, :show]

  resources :suppliers,param: :code, only: [:index, :show]

  resources :item_types,param: :code, only: [:index, :show]

  resources :brands,param: :code, only: [:index, :show]

  resources :discounts, only: [:index, :show, :create, :show, :update, :destroy] do
    post :refresh_active_promotion, on: :collection
    post :refresh_all_promotion, on: :collection
    post :refresh_promotion, on: :member
    get :columns, on: :collection
    delete :delete_inactive_past_discount, on: :collection
    get :template_mass_upload_excel, on: :collection
  end

  resources :sales, only:[] do
    get :transaction_report, on: :collection
  end

  resources :item_sales, only:[] do
    get :transaction_report, on: :collection
    get :period_report, on: :collection
  end

  resources :employee_attendances, only: [:index, :create, :destroy] do
    post :mass_upload, on: :collection
  end

  resources :payslips, only:[:index, :show, :update] do
    post :generate_payslip, on: :collection
    post :confirm, on: :member
    post :cancel, on: :member
    post :pay, on: :member
  end

  resources :assets, param: :code, only: [:show, :create]

  resources :employees, param: :code, only:[:index,:create,:update] do
    post :activate, on: :member
    post :deactivate, on: :member
  end

  resources :roles, only: [:index,:show, :create, :update, :destroy] do
    get :controller_names, on: :collection
    get :action_names, on: :collection
    get :table_names, on: :collection
    get :column_names, on: :collection
  end
  resources :payrolls, only: [:index, :show, :create, :update, :destroy]
  resources :employee_leaves, only: [:index, :show, :create, :update, :destroy]
  resources :access_authorizes, only: [:index, :show, :create, :update, :destroy]
  resources :column_authorizes, only: [:index, :show, :create, :update, :destroy]
end
