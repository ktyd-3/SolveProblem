Rails.application.routes.draw do
  root to: "ideas#theme"
  resources :ideas do
    member do
      post 'edit'
      get 'solution'
      get "ex_form"
      get "first_solution"
      get 'tree'
      get 'evaluate'
      get 'generate_graph'
      get 'search'
      patch 'set_easy_points'
      patch 'set_effect_points'
      get 'score_graph'
      delete 'solution', to: 'ideas#destroy'
      delete "destroy_move"
      get 'small_tree'
      post "parent_create"
      patch "update_easy_value"
      patch "update_effect_value"
    end

    collection do
      get "theme"
      post 'first_create'
      get "signup", to: "users#new"
      post "signup", to: "users#create"
      get "login", to: "sessions#new"
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"
    end
  end

end
