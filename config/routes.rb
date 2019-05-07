Rails.application.routes.draw do
  root to: 'requests#new'
  resources :requests, only: [:new, :create] do
    get 'confirm_email', on: :member
  end
end
