Rails.application.routes.draw do
  root to: "ideas#index"
  resources :ideas do
    member do
      patch 'update'
    end

    collection do
      post 'first_create'
      get 'solution'
    end
  end
end
