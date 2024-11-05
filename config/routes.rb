Rails.application.routes.draw do
  root 'home#index'
  post 'increment_count', to: 'home#increment'

  # Keep existing health check and PWA routes
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
