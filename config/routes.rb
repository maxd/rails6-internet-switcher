Rails.application.routes.draw do
  root to: 'internet#index'

  namespace :api do
    resource :internet, controller: :internet, only: [] do
      member do
        get :is_enabled
        post :enable
      end
    end
  end

  resource :internet, controller: :internet, only: [ :index ]
end
