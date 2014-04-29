Hearthstats::Application.routes.draw do

	# Gem routes
  #
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  opinio_model
  mount RedactorRails::Engine => '/redactor_rails'

  get "cards/index"
  get "streams/index"

  resources :teams

	# match '(*foo)' => 'additional#serverupgrade'
  resources :tournies do
    collection do
      get 'signup'
      get 'past'
      post 'regtourny'
      post 'createtourny'
    end
  end

  # Notifications

  post "notifications/note_read"

  opinio_model :controller => 'my_comments'
  # get "profile/edit"

  match "/contactus", to: "additional#contactus"
  match "/aboutus", to: "additional#aboutus"
  match "/help", to: "additional#help"
  match "/changelog", to: "additional#changelog"
  match "/privacy", to: "additional#privacy"
  match "/news", to: "additional#news"
  match "/openings", to: "additional#openings"

  #apps
  match "/uploader", to: "additional#uploader"
  match "/uploader/download/win", to: "additional#uploader_download_win"
  match "/uploader/download/osx", to: "additional#uploader_download_osx"

  # Monthly Reports
  match '/jan', :to => redirect('/reports/jan/index.html')
  match "/dec", to: "welcome#decreport"
  match "/nov", to: "welcome#novreport"
  match "/mar", :to => redirect('/reports/mar/index.html')

  # Admin Stats Export

  get "admin/export_arena"
  get "admin/export_con"

  get "welcome/index"
  get "welcome/demo_user"

  resources :arena_runs do
    collection do
      get 'end'
      post 'endrun'
    end
  end
  match "/arena/matches", to: "arenas#matches"

  match "decks/:id/copy", to: "decks#copy"
  resources :profiles do
    get 'sig'
  end
  resources :decks do
  	collection do
      get 'active_decks'
      get 'public'
      post 'submit_active_decks'
  	end
    get 'version', on: :member
  end

  resources :decks do
    opinio
  	collection do
      get 'copy'
    end
  end
  resources :dashboards do
    collection do
      get 'race'
      get 'fullstats'
    end
  end

  # devise_for :users
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => {:registrations => "registrations"}
  ActiveAdmin.routes(self)
  resources :constructeds do
    collection do
      get :stats
    end
  end

  # devise_for :users
  ActiveAdmin.routes(self)
  devise_for :users, :controllers => {:registrations => "registrations"}
  ActiveAdmin.routes(self)
  resources :cards do
    collection do
    end
  end


  resources :arenas do
    collection do
      get :archives
      get :stats
      post :quickentry
    end
  end
  authenticated :user do
    root :to => 'dashboards#index'
  end

  devise_scope :user do
    root to: "welcome#index"
  end

  resources :matches
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

      post "matches/new"

	    get "decks/show"
	    get "decks/find"
      post "decks/activate"
      post "decks/slots"
		end

		namespace :v2 do
			devise_for :users
  		get "arenas/show"
	    post "arenas/new"

	    get "constructeds/show"
	    post "constructeds/new"

	    get "arena_runs/show"
	    post "arena_runs/new"
	    get "arena_runs/end"

      post "matches/new"

	    get "decks/show"
	    get "decks/find"
      post "decks/activate"
      post "decks/slots"
		end
  end
end
