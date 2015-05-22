Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reports, only: [:index] do
      collection do
        get :export_orders
        post :export_orders, as: :background_export_orders, to: :background_export_orders
      end
    end
  end
end
