Rails.application.routes.draw do
  root "incidents#index"
  
  resources :incidents do
    member do
      get :recommend_priority
      patch :update_priority
    end
  end
end
