# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :readings, only: %i[create show]
      resources :stats, only: [:index]
    end
  end
end
