Rails.application.routes.draw do
  resources :urls

  get '/:shortened', to: 'urls#shortened'

  root :to => 'urls#index'
end
