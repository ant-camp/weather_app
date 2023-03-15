# frozen_string_literal: true

Rails.application.routes.draw do
  get 'forecast', to: 'forecast#index', as: 'forecast'
  root "forecast#index"
end
