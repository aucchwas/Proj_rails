Rails.application.routes.draw do
  get "players/index"
  get "players/show"
  get "static_pages/about"
  root "static_pages#home"
  get "search", to: "teams#search", as: "search_teams"

  resources :leagues do
    resources :teams, only: [ :index, :show ]
  end
  resources :teams
  resources :players

   get "home", to: "static_pages#home", as: "home"
   get "about", to: "static_pages#about", as: "about"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
