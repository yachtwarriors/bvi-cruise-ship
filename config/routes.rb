Rails.application.routes.draw do
  devise_for :admins, path: "", path_names: { sign_in: "login", sign_out: "logout" },
             skip: [:registrations]

  root "pages#home"

  namespace :admin do
    root "dashboard#index"
    resources :thresholds, only: [:index, :update]
    resources :configs, only: [:index, :update]
    post "recalculate", to: "dashboard#recalculate"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
