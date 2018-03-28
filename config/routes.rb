Rails.application.routes.draw do

  # Commons.
  root 'top#index'
  get '/current_log',   to: 'top#current_log'

  # Total SIM stats.
  get '/total_sim_stats/latest',    to: 'total_sim_stats#latest', as: 'total_sim_stats'

  # Zero SIM stats.
  get '/zero_sim_stats',            to: 'zero_sim_stats#stats',   as: 'zero_sim_stats'
  get '/zero_sim_stats/api/debug',  to: 'zero_sim_stats#debug'
  get '/zero_sim_stats/api/sync',   to: 'zero_sim_stats#sync'
  get '/zero_sim_stats/api/notify', to: 'zero_sim_stats#notify'

  # DCM SIM stats REST APIs.
  get '/dcm_sim_stats',             to: 'dcm_sim_stats#stats',    as: 'dcm_sim_stats'
  get '/dcm_sim_stats/api/debug',   to: 'dcm_sim_stats#debug'
  get '/dcm_sim_stats/api/sync',    to: 'dcm_sim_stats#sync'
  get '/dcm_sim_stats/api/notify',  to: 'dcm_sim_stats#notify'

  # Nuro SIM stats REST APIs.
  get '/nuro_sim_stats',            to: 'nuro_sim_stats#stats',   as: 'nuro_sim_stats'
  get '/nuro_sim_stats/api/debug',  to: 'nuro_sim_stats#debug'
  get '/nuro_sim_stats/api/sync',   to: 'nuro_sim_stats#sync'
  get '/nuro_sim_stats/api/notify', to: 'nuro_sim_stats#notify'

  # Client bridge.
  namespace :api, { format: 'json' } do
    post  '/client_bridge/register_fcm'
  end

end
