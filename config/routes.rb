Rails.application.routes.draw do
  devise_for :admins, path: "", path_names: { sign_in: "login", sign_out: "logout" },
             skip: [:registrations]

  devise_for :users, path: "users", path_names: { sign_in: "login", sign_up: "signup" }

  resource :account, only: [:show, :update], controller: "accounts"

  root "pages#home"

  namespace :manage do
    root "dashboard#index"
    resources :thresholds, only: [:index, :update]
    resources :configs, only: [:index, :update]
    post "recalculate", to: "dashboard#recalculate"
  end

  get "/sitemap.xml", to: "sitemap#index", defaults: { format: "xml" }, as: :sitemap

  get "up" => "rails/health#show", as: :rails_health_check
end
