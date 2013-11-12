Hearthstats::Application.routes.draw do
  # get "profile/index"

  # get "profile/edit"

  get "additional/contactus"
  get "additional/aboutus"
  get "additional/help"
  get "additional/changelog"
  match "/nov", to: "welcome#novreport"

  get "admin/index"
  get "admin/addprofileuserid"
  get "admin/announcement"
  post "admin/anncreate"

  
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
