Rails.application.routes.draw do
  root to: 'requests#new'
  resource :requests, only: [:new, :create]
end
