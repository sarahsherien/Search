Rails.application.routes.draw do
  root 'search#index'
  post 'search_logs', to: 'search_logs#create'
  get 'analytics', to: 'analytics#index'
end
