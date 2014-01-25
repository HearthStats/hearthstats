Hearthstats::Application.routes.draw do
  mount RedactorRails::Engine => '/redactor_rails'

  get "streams/index"

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
  match "/news", to: "additional#news"

  # Monthly Reports
  match "/jan", to: "welcome#janreport"
  match "/dec", to: "welcome#decreport"
  match "/nov", to: "welcome#novreport"

  get "admin/index"
  get "admin/addprofileuserid"
  get "admin/announcement"
  post "admin/anncreate"
  get "admin/new_patch"
  post "admin/update_patch"

  get "welcome/index"
  get "welcome/demo_user"

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

  # HearthStats API
  namespace :api do
  	namespace :v1 do
  		get "arenas/show"
	    post "arenas/new"

	    get "constructeds/show"
	    post "constructeds/new"

	    get "arena_runs/show"
	    post "arena_runs/new"
	    get "arena_runs/end"
		end
  end


end
