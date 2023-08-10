Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :reports, only: [] do
    get :item_sales_percentage, on: :collection
  end

  resources :items, only: [:index, :show]

  resources :suppliers, only: [:index, :show]

  resources :item_types, only: [:index, :show]
  
  resources :brands, only: [:index, :show]
  
end
