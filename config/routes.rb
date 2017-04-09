Rails.application.routes.draw do
  devise_for :users
  #scope "(:locale)", locale: /en|vi|ja/ do
  devise_scope :user do
    root to: "devise/sessions#new"
  end

  get 'home' => 'static_pages#home'

  namespace :students do
    resources :users
  end

  namespace :teachers do
    resources :users
    resources :courses do
      resources :lessons
    end
  end

  namespace :admins do
    resources :users
    resources :categories
    resources :courses
    resources :set_status_courses, only: :index
  end

  namespace :publish do
    resources :posts
    resources :rooms
  end


    # resources :workspaces do
    #   resource :user_workspaces, except: [:show]
    # end
end
