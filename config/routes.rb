Rails.application.routes.draw do
  root to: "ideas#index"
  resources :ideas do
    member do
      get 'first_create'
      post 'first_create'
    end

    collection do
      post 'first_create'
      get 'solution'
    end
  end
end
