Rails.application.routes.draw do
  # Redirect www → apex (canonical domain) with 301
  constraints host: "www.bvicruiseshipschedule.com" do
    get "(*path)", to: redirect { |params, req|
      query = req.query_string.presence
      "https://bvicruiseshipschedule.com/#{params[:path]}#{query ? "?#{query}" : ''}"
    }
  end

  devise_for :users, path: "", path_names: { sign_in: "login", sign_up: "signup", sign_out: "logout" }

  resource :account, only: [:show, :update], controller: "accounts"

  root "pages#home"

  get "/usvi", to: "usvi#show", as: :usvi
  get "/us-virgin-islands-cruise-ship-schedule", to: redirect("/usvi", status: 301)
  get "/st-thomas-cruise-ship-schedule", to: redirect("/usvi", status: 301)

  # Port pages
  get "/tortola" => "ports#show", slug: "road-town", as: :tortola
  get "/virgin-gorda" => "ports#show", slug: "virgin-gorda", as: :virgin_gorda
  get "/st-thomas" => "ports#show", slug: "charlotte-amalie", as: :st_thomas
  get "/st-croix" => "ports#show", slug: "frederiksted", as: :st_croix

  # Beach/attraction pages
  get "/the-baths" => "locations#show", slug: "the-baths", as: :the_baths
  get "/cane-garden-bay" => "locations#show", slug: "cane-garden-bay", as: :cane_garden_bay
  get "/white-bay" => "locations#show", slug: "white-bay", as: :white_bay
  get "/magens-bay" => "locations#show", slug: "magens-bay", as: :magens_bay
  get "/coki-beach" => "locations#show", slug: "coki-beach", as: :coki_beach
  get "/national-park-beaches" => "locations#show", slug: "national-park-beaches", as: :national_park_beaches
  get "/rainbow-beach" => "locations#show", slug: "rainbow-beach", as: :rainbow_beach
  get "/buck-island" => "locations#show", slug: "buck-island", as: :buck_island

  namespace :manage do
    root "dashboard#index"
    resources :thresholds, only: [:index, :update]
    resources :configs, only: [:index, :update]
    post "recalculate", to: "dashboard#recalculate"
  end

  get "/sitemap.xml", to: "sitemap#index", defaults: { format: "xml" }, as: :sitemap

  get "up" => "rails/health#show", as: :rails_health_check
end
