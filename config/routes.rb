Hearthstats::Application.routes.draw do
  resources :decks
  resources :dashboards do
    collection do
      get 'race'
    end
  end
  devise_for :users
  resources :constructeds


  resources :arenas
  authenticated :user do
    root :to => 'dashboards#index'
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
