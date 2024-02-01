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

  resources :employee_payslips, only:[:index, :update] do
    post :generate_payslip, on: :collection
    post :confirm, on: :member
    post :cancel, on: :member
    post :pay, on: :member
  end
end
