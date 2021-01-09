Rails.application.routes.draw do
  root to: 'internet#index'

  namespace :api do
    resource :internet, controller: :internet, only: [] do
      member do
        get :status
        post :enable
      end
    end
  end

  devise_for :users

  resource :internet, controller: :internet, only: [ :index ]
end
