Rails.application.routes.draw do
  root to: "ideas#index"
  resources :ideas do
    member do
      get 'edit'
      get '/solution/:id', to: 'ideas#solution'
      get 'solution'
      get "/ex_form/:id", to: 'ideas#ex_form'
      get "ex_form"
      get "first_solution"
    end

    collection do
      get "theme"
      post 'first_create'
      patch 'set_easy_points'
      patch 'set_effect_points'
      get 'evaluate'
      get 'tree'
      get 'score_graph'
      get 'generate_graph'
      get 'search'
    end
  end

end
