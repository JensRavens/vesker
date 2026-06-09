Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Passwordless login (two steps, rendered inside a modal): email → emailed code.
  resource :session, only: [:new, :create], path: "login" do
    patch :verify, on: :collection
  end
  delete "logout", to: "sessions#destroy"

  # Register a passkey for the signed-in user (the login modal's post-login step).
  resources :passkeys, only: [:create]

  resources :albums, only: [:show, :new, :update] do
    resources :moments, only: [:show, :destroy] do
      resource :like, only: [:create, :destroy]
      resources :comments, only: [:create]
    end
    resources :uploads, only: [:new, :create]
    get :people, on: :member
    get :menu, on: :member
    get :share, on: :member
    get :edit, on: :member
    get :download, on: :member
  end
  get "files/:id", to: "shimmer/files#show", as: :file

  # Web app manifest (rendered from app/views/pwa/manifest.json.erb), linked in the layout head.
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest

  # The landing page that prompts visitors to create an album (the only way in besides a shared link).
  root "albums#index"
end
