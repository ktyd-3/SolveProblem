Rails.application.routes.draw do
  root to: "ideas#index"
  resources :ideas do
    member do
      patch 'update'
      get 'solution'
    end

    collection do
      post 'first_create'
      patch 'set_easy_points'
      patch 'set_effect_points'
      get 'evaluate'
    end
  end
  get 'ideas/solution/:id', to: 'ideas#solution'
end
