Rails.application.routes.draw do
  root to: "ideas#index"
  resources :ideas do
    member do
      patch 'update'
      post 'solution/:id', action: :solution
    end

    collection do
      post 'first_create'
    end
  end
end
