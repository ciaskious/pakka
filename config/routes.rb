Rails.application.routes.draw do
  get "users/profile"
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Homepage
  root to: "pages#home"

  get "/ui-kit", to: "pages#ui_kit"

  # Trips & Checklists
  resources :trips do
    member do
      post :duplicate
      get :share, to: "trips#public_show"
    end

    collection do
      get :public_index, path: "community"
    end

    resources :checklist_items, path: "items", only: [:create]
  end

  resources :checklist_items, path: "trip_items", only: [:update, :destroy]

  get "/profile", to: "users#profile", as: :profile
  resources :items, except: [:show]

  # User Profile
  resource :user do
    patch '/users/avatar', to: 'users#update_avatar', as: :user_avatar
  end

  # Reusable Items
  resources :reusable_items
  resources :checklist_items do
    member do
      patch :toggle
    end
  end

  # APIs
  post "/geocode", to: "locations#geocode"
  get "/weather", to: "weather#forecast"
  get "/accommodation", to: "lodging#accommodation_details"

  # OpenAI endpoints
  post "/ai/suggest", to: "openai#suggest_items"
  post "/ai/summary", to: "openai#summary"
end
