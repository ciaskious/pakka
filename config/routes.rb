Rails.application.routes.draw do
  get "users/profile"
  devise_for :users
  # Auth (devise ou perso)
  # devise_for :users

  # Homepage
  root to: "pages#home"

  get "/ui-kit", to: "pages#ui_kit"

  # Trips & Checklists
  resources :trips do
    member do
      post :duplicate       # /trips/:id/duplicate
      get :share, to: "trips#public_show"  # /trips/:id/share
    end

    collection do
      get :public_index, path: "community"  # /community
    end

    resources :checklist_items, path: "items", only: [:create]
  end

  resources :checklist_items, path: "trip_items", only: [:update, :destroy]

  get "/profile", to: "users#profile", as: :profile
  resources :items, except: [:show]

  # APIs
  post "/geocode", to: "locations#geocode"
  get "/weather", to: "weather#forecast"
  get "/accommodation", to: "lodging#accommodation_details"

  # OpenAI endpoints
  post "/ai/suggest", to: "openai#suggest_items"
  post "/ai/summary", to: "openai#summary"
end
