Hearthstats::Application.routes.draw do
	# match '(*foo)' => 'additional#serverupgrade'
  resources :tournies do
    collection do
      get 'signup'
      get 'past'
      post 'regtourny'
      post 'createtourny'
    end
  end
  # get "profile/index"

  # get "profile/edit"

  match "/contactus", to: "additional#contactus"
  match "/aboutus", to: "additional#aboutus"
  match "/help", to: "additional#help"
  match "/changelog", to: "additional#changelog"
  match "/nov", to: "welcome#novreport"

  get "admin/index"
  get "admin/addprofileuserid"
  get "admin/announcement"
  post "admin/anncreate"

  get "welcome/index"
  post "welcome/demo_user"
  # resources :welcome do
  #   collection do
  #     get 'index'
  #     post 'demo_user'
  #   end
  # end
  resources :arena_runs do
    collection do
      get 'end'
      post 'endrun'
    end
  end


  resources :profiles
  resources :decks
  resources :dashboards do
    collection do
      get 'race'
      get 'fullstats'
    end
  end

  # devise_for :users
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :constructeds do
    collection do
      get :stats
    end
  end


  resources :arenas do
    collection do
      get :archives
      get :stats
    end
  end
  authenticated :user do
    root :to => 'dashboards#index'
  end

  devise_scope :user do
    root to: "welcome#index"
  end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
