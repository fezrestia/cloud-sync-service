class RootController < ApplicationController

  def root
    @error_logs = ErrorLog.all.load
  end

  def delete_error_log
    id = param_error_log_id
    log = ErrorLog.find(id)

    log.delete

    redirect_to root_root_path
  end



  private

    def param_error_log_id
      return params[:error_log_id]
    end



  # private

end
