Rails.application.routes.draw do
  root to: "ideas#top"
  resources :ideas do
    member do
      post 'edit'
      get 'solutions'
      get "ex_form"
      get "first_solution"
      get 'tree'
      get 'evaluations'
      get 'generate_graph'
      get 'search'
      patch 'set_easy_points'
      patch 'set_effect_points'
      get 'results'
      delete 'solution', to: 'ideas#destroy'
      delete "destroy_move"
      get 'small_tree'
      post "parent_create"
      patch "update_easy_value"
      patch "update_effect_value"
      get "add_weighted_value"
      get "remove_weighted_value"
      patch "public_setting"
      get "copy_idea_generation"
      get "copy_create_children"
      get "public_custom"
      get "change_to_themes"
      post "to_theme"
    end

    collection do
      get "top"
      get "themes"
      post 'first_create'
      get "signup", to: "users#new"
      post "signup", to: "users#create"
      get "login", to: "sessions#new"
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"
    end
  end

end
