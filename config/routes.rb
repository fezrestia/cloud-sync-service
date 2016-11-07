Rails.application.routes.draw do
  get 'top/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'top#index'

  # 0 SIM checker routes.
  get       '/zero_sim_usages'        => 'zero_sim_usages#index'
  get       '/zero_sim_usages/new'    => 'zero_sim_usages#new'
  post      '/zero_sim_usages'        => 'zero_sim_usages#create'
  get       '/zero_sim_usages/:id'    => 'zero_sim_usages#show'
  delete    '/zero_sim_usages/:id'    => 'zero_sim_usages#destroy'
  # 0 SIM Usage REST APIs.
  get       '/zero_sim_usages/api/sync',
                to: 'zero_sim_usages#sync'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
