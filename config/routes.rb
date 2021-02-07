Rails.application.routes.draw do
  root to: 'internet#index'

  devise_for :users

  resource :internet, controller: :internet, only: [ :index ] do
    member do
      post :enable
    end
  end
end
