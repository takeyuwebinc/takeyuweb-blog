Rails.application.routes.draw do
  root 'static#index'

  namespace :api do
    resources :posts
  end

  get '*path', to: 'static#index'
end
