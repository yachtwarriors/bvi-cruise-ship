Rails.application.routes.draw do
  devise_for :users, path: "", path_names: { sign_in: "login", sign_up: "signup", sign_out: "logout" }

  resource :account, only: [:show, :update], controller: "accounts"

  root "pages#home"

  get "/usvi", to: "usvi#show", as: :usvi
  get "/us-virgin-islands-cruise-ship-schedule", to: redirect("/usvi", status: 301)
  get "/st-thomas-cruise-ship-schedule", to: redirect("/usvi", status: 301)

  namespace :manage do
    root "dashboard#index"
    resources :thresholds, only: [:index, :update]
    resources :configs, only: [:index, :update]
    post "recalculate", to: "dashboard#recalculate"
  end

  get "/sitemap.xml", to: "sitemap#index", defaults: { format: "xml" }, as: :sitemap

  get "up" => "rails/health#show", as: :rails_health_check
end
