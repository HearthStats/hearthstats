Hearthstats::Application.routes.draw do

  # Gem routes
  #
  match '/s/:id' => "shortener/shortened_urls#show"

  # Delayed_job_web
  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  opinio_model

  get "cards/index"
  get "streams/index"

  resources :teams
  resources :premiums do
    post 'cancel', on: :collection
    get 'report', on: :collection
    get 'gen_report', on: :collection
  end
  # match '(*foo)' => 'additional#serverupgrade'
  resources :tournies do
    collection do
      post 'signup'
      get 'past'
      post 'regtourny'
      post 'createtourny'
      get 'calendar'
    end
  end

  resources :blind_drafts do
    member do
      put "reveal_card"
      put "pick_card"
      put "new_card"
      get "draft"
      post "end_draft"
      post "create_deck"
    end
  end

  # Notifications

  post "notifications/note_read"

  opinio_model controller: 'my_comments'
  # get "profile/edit"

  match "/contactus", to: "additional#contactus"
  match "/aboutus", to: "additional#aboutus"
  match "/help", to: "additional#help"
  match "/changelog", to: "additional#changelog"
  match "/privacy", to: "additional#privacy"
  match "/news", to: "additional#news"
  match "/openings", to: "additional#openings"
  match "/contest", to: "additional#contest_video"
  match "/league", to: "additional#league"

  #apps
  match "/uploader", to: "additional#uploader"
  match "/uploader/download/win", to: "additional#uploader_download_win"
  match "/uploader/download/osx", to: "additional#uploader_download_osx"

  # Monthly Reports
  match '/jan', to: redirect('/reports/jan/index.html')
  match "/dec", to: "welcome#decreport"
  match "/nov", to: "welcome#novreport"
  match "/mar", to: redirect('/reports/mar/index.html')
  match "/apr", to: "welcome#april_report"
  match "/may", to: "welcome#may_report"
  match "/june", to: "welcome#june_report"
  match "/july", to: "welcome#july_report"
  match "/aug", to: "welcome#aug_report"
  match "/sept", to: "welcome#sept_report"
  match "/sept_post", to: "welcome#sept_post_report"
  match "/oct", to: "welcome#oct_report"
  match "/gen_report", to: "welcome#generate_report"
  match "/gvg", to: "welcome#gvgreport"
  get "welcome/ranked_test"
  get "welcome/select_klass"

  # Admin Stats Export

  get "admin/export_arena"
  get "admin/export_con"
  match "admin/ann", to: "admin#ann"
  post "admin/anncreate"
  get "admin/test_page"
  post "admin/toggle_sub"

  get "welcome/index"
  get "welcome/demo_user"
  post "welcome/newsletter_sub"

  resources :arena_runs do
    collection do
      get 'end'
      post 'endrun'
    end
  end

  resources :profiles do
    member do
      get 'activities'
    end
    post 'set_locale', on: :collection
  end

  resources :decks do
    opinio
    collection do
      get 'active_decks'
      get 'public'
      get 'merge'
      post 'submit_merge'
      get 'new_splash'
      post 'submit_active_decks'
      get 'copy'
      get 'tags'
    end

    member do
      post 'version'
      post 'delete_active'
      get 'public_show'
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
  devise_for :users, controllers: {registrations: "registrations"}
  resources :constructeds do
    collection do
      get :stats
      post :quick_create
      get :win_rates
      get :reset
    end
  end

  resources :cards

  resources :tournaments do
    member do
      post :submit_deck
      post :join
      post :quit
      post :start
      post :remove_player
    end
  end

  resources :tourn_matches do
    opinio
  end

  resources :tourn_pairs do
    member do
      post :delete_match
      post :add_match
    end
  end

  resources :arenas do
    collection do
      get :archives
      get :stats
      post :quickentry
      get :matches
      get :reset
    end
  end

  root to: "welcome#index"

  resources :matches do
    delete :delete_all, on: :collection
    get :replay, on: :member
    opinio
  end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  # HearthStats API
  namespace :api, defaults:{format: 'json'} do
    namespace :v1 do
      resources :cards
      get "arenas/show"
      post "arenas/new"

      get "constructeds/show"
      post "constructeds/new"

      get "arena_runs/show"
      post "arena_runs/new"
      get "arena_runs/end"


      post "matches/new"
      post "matches/delete"

      get "decks/show"
      get "decks/find"
      post "decks/delete"
      post "decks/activate"
      post "decks/slots"
      get "users/premium"
      post "decks/create"
    end

    namespace :v2 do
      devise_for :users
      resources :cards
      get "users/premium"
      get "arenas/show"
      post "arenas/new"

      get "constructeds/show"
      post "constructeds/new"

      get "arena_runs/show"
      post "arena_runs/new"
      get "arena_runs/end"

      post "matches/new"
      get "matches/query"
      post "matches/delete"

      get "decks/show"
      get "decks/find"
      post "decks/activate"
      post "decks/create"
      post "decks/slots"
      post "decks/delete"

      # HDT APIs
      post "decks/hdt_create"
      post "decks/hdt_after"
      post "decks/create_version"
      post "decks/hdt_edit"
      post "deck_versions/hdt_after"
      post "matches/hdt_new"
      post "matches/hdt_after"
      post "matches/move"
    end
  end
end
