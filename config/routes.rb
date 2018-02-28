Rails.application.routes.draw do

  root 'top#index'

  # Zero SIM stats.
  get '/zero_sim_stats',  to: 'zero_sim_stats#stats',  as: 'zero_sim_stats'

  # Zero SIM stats REST APIs.
  get '/zero_sim_stats/api/debug',   to: 'zero_sim_stats#debug'
  get '/zero_sim_stats/api/sync',    to: 'zero_sim_stats#sync'
  get '/zero_sim_stats/api/notify',  to: 'zero_sim_stats#notify'

  # Client bridge.
  namespace :api, { format: 'json' } do
    post  '/client_bridge/register_fcm'
  end

end
