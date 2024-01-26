Rails.application.routes.draw do
  root to: "ideas#theme"
  resources :ideas do
    member do
      get 'edit'
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

    end

    collection do
      get "theme"
      post 'first_create'
    end
  end

end
