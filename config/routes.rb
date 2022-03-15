# frozen_string_literal: true

Rails.application.routes.draw do
  root 'components#index'

  namespace :api do
    namespace :v1 do
      resources :sessions, only: %i[create destroy] do
        collection do
          get 'signed_in', to: 'sessions#signed_in'
        end
      end
    end
  end

  get '*path', to: 'components#index', via: :all # Undefined Rails Routes will redirect to React homepage
end
