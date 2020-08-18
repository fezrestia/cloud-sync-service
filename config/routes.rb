Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Root.
  get '/', to: 'root#root', as: 'root_root'

  # Watch dog.
  post  '/trigger_watch_dog', to: 'root#trigger_watch_dog'
  get   '/trigger_watch_dog', to: 'root#trigger_watch_dog_and_reload',  as: 'trigger_watch_dog_and_reload'

  # Error Logs.
  post  '/delete_error_log',      to: 'root#delete_error_log'
  get   '/delete_error_log/:id',  to: 'root#delete_error_log_and_reload',  as: 'delete_error_log_and_reload'

  # SIM stats.
  namespace :sim_stats do
    get '/total_sim_stats/latest',    to: 'total_sim_stats#latest', as: 'total'
    get '/dcm_sim_stats',             to: 'dcm_sim_stats#stats',    as: 'dcm'
    get '/nuro_sim_stats',            to: 'nuro_sim_stats#stats',   as: 'nuro'
    get '/zero_sim_stats',            to: 'zero_sim_stats#stats',   as: 'zero_sim'
  end



end
