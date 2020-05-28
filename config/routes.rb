Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reports, only: [:index] do
      collection do
        post 'export_orders', as: :background_export_orders, to: 'reports#background_export_orders'
        get 'export_orders'
      end
    end
  end
end
