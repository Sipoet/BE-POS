Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  get 'settings', to: 'home#settings'
  get 'check_update/:platform', to: 'home#check_update'
  get 'download_app/:platform', to: 'home#download_app', as: :download_app

  devise_for :users, path: '', path_names: {
                                 sign_in: 'login',
                                 sign_out: 'logout'
                               },
                     controllers: {
                       sessions: 'users/sessions'
                     }
  mount Rswag::Api::Engine => 'api-docs'
  mount Rswag::Ui::Engine => 'api-blueprint', at: 'api-blueprint'
  root to: redirect { '/api-blueprint' }
  resources :activity_logs, only: [:index] do
    get :by_item, on: :collection
    get :by_user, on: :collection
  end

  resources :users, param: :username, only: %i[index show destroy update create] do
    post :unlock_access, on: :member
  end
  resources :background_jobs, only: %i[index show destroy] do
    post :retry, on: :member
    post :cancel, on: :member
  end

  resources :item_reports, only: [:index] do
    get :columns, on: :collection
    get :grouped_report, on: :collection
  end

  resources :items, param: :code, only: %i[index show update] do
    get :with_discount, on: :collection
    get :download, on: :collection
  end

  resources :suppliers, param: :code, only: %i[index show]

  resources :item_types, param: :code, only: %i[index show]

  resources :brands, param: :code, only: %i[index show]

  resources :discounts, only: %i[index show create show update destroy] do
    post :refresh_active_promotion, on: :collection
    post :refresh_all_promotion, on: :collection
    post :refresh_promotion, on: :member
    get :columns, on: :collection
    delete :delete_inactive_past_discount, on: :collection
    get :template_mass_upload_excel, on: :collection
    get :download_items, on: :member
    get :download_active_items, on: :collection
  end

  resources :sales, only: %i[index show] do
    get :transaction_report, on: :collection
    get :daily_transaction_report, on: :collection
    get :report, on: :collection
  end

  resources :purchases, only: %i[index show] do
    get :report, on: :collection
    post :refresh_report, on: :collection
    post :update_price, on: :member
  end

  resources :purchase_orders, only: %i[index show] do
    post :update_price, on: :member
  end

  resources :consignment_ins, only: %i[index show] do
    post :update_price, on: :member
  end

  resources :consignment_in_orders, only: %i[index show] do
    post :update_price, on: :member
  end

  resources :purchase_returns, only: %i[index show]

  resources :purchase_items, only: [:index]

  resources :transfers, only: %i[index show]
  resources :locations, only: %i[index show]
  resources :transfer_items, only: [:index]

  resources :sale_items, only: [:index] do
    get :transaction_report, on: :collection
    get :period_report, on: :collection
  end

  resources :employee_attendances, only: %i[index create destroy update] do
    post :mass_upload, on: :collection
    post :mass_update_allow_overtime, on: :collection
  end

  resources :payslips, only: %i[index show update destroy] do
    post :generate_payslip, on: :collection
    post :confirm, on: :member
    post :cancel, on: :member
    post :pay, on: :collection
    get :report, on: :collection
    get :download, on: :member
    get :send_email, on: :member
  end

  resources :assets, param: :code, only: %i[show create]

  resources :employees, only: %i[index show create update] do
    post :activate, on: :member
    post :deactivate, on: :member
  end

  resources :roles, only: %i[index show create update destroy] do
    get :controller_names, on: :collection
    get :action_names, on: :collection
    get :table_names, on: :collection
    get :column_names, on: :collection
  end
  resources :payrolls, only: %i[index show create update destroy] do
    get :report, on: :collection
  end
  resources :employee_leaves, only: %i[index show create update destroy]
  resources :cashier_sessions, only: %i[index show create update] do
    resources :edc_settlements, only: [:index] do
      get :check_edc, on: :collection
    end
  end
  resources :edc_settlements, only: %i[create update destroy]
  resources :payment_providers, only: %i[index show create update destroy]
  resources :payment_types, only: %i[create update index]
  resources :payment_provider_edcs, only: %i[create update index destroy]
  resources :payment_methods, only: %i[index destroy create update]
  resources :banks, only: [:index]
  resources :customer_groups, only: [:index]
  resources :customer_group_discounts, only: %i[index create update destroy] do
    post :toggle_discount, on: :collection
  end
  resources :payroll_types, only: %i[index create update destroy]
  resources :holidays, only: %i[index create update destroy]
  resources :book_payslip_lines, only: %i[index create update destroy]
  resources :book_employee_attendances, only: %i[index create update destroy]
  resources :accounts, only: %i[index show]
  resources :system_settings, only: %i[index show update] do
    post :refresh_table, on: :collection
    get :list_tables, on: :collection
  end

  resources :item_sales_performance_reports, only: [:index] do
    get :group_by, on: :collection
  end

  resources :monthly_expense_reports, only: [:index] do
    get :group_by, on: :collection
  end

  scope :ipos do
    resources :users, controller: 'ipos/users', only: [:index]
  end
end
