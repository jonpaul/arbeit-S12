Arbeit::Application.routes.draw do
  
  # Routes for main resources
  resources :domains
  resources :projects
  resources :tasks
  resources :assignments
  resources :users
  resources :sessions
  
  # Authentication routes
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login

  # Semi-static page routes
  match 'home' => 'home#home', :as => :home
  match 'about' => 'home#about', :as => :about
  match 'contact' => 'home#contact', :as => :contact
  match 'privacy' => 'home#privacy', :as => :privacy
  match 'search' => 'home#search', :as => :search
  
  # Set the root url
  root :to => 'home#home'
  
  # Named routes
  match 'completed/:id' => 'tasks#complete', :as => :complete
  match 'incomplete/:id' => 'tasks#incomplete', :as => :incomplete
end
