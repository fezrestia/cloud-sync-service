Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Root.
  get '/', to: 'root#root', as: 'root_root'

  # Error Logs.
  post '/delete_error_log', to: 'root#delete_error_log', as: 'delete_error_log'

  # SIM stats.
  namespace :sim_stats do
    get '/total_sim_stats/latest',    to: 'total_sim_stats#latest', as: 'total'
    get '/dcm_sim_stats',             to: 'dcm_sim_stats#stats',    as: 'dcm'
    get '/nuro_sim_stats',            to: 'nuro_sim_stats#stats',   as: 'nuro'
    get '/zero_sim_stats',            to: 'zero_sim_stats#stats',   as: 'zero_sim'
  end



end
