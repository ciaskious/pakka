Rails.application.routes.draw do
  # Devise stuff & profile
  devise_for :users, controllers: { registrations: "users/registrations" }
  get "/profile", to: "users#profile", as: :profile

  # Static pages
  root to: "pages#home"
  get "/ui-kit", to: "pages#ui_kit"

  # Trips & Checklists
  resources :trips do
    resources :checklist_items,
              path: "items",
              only: %i[create edit update destroy]

    patch :toggle_public, on: :member

    member do
      post :duplicate
      post :generate_ai_suggestions
      post :add_multiple_suggestions
    end

    collection do
      get :public_index, path: "community"
    end
  end

  resources :items, except: [:show]

  # User avatar update
  resource :user, only: [] do
    patch :update_avatar, path: "avatar"
  end

  # APIs
  post "/geocode", to: "locations#geocode"
  get "/weather", to: "weather#forecast"
  get "/accommodation", to: "lodging#accommodation_details"

  # OpenAI endpoints
  post "/ai/suggest", to: "openai#suggest_items"
  post "/ai/summary", to: "openai#summary"
end
