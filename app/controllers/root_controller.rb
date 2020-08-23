class RootController < ApplicationController

  def root
    if IS_DB_ENABLED
      @error_logs = ErrorLog.all.load
    else
      @error_logs = []
    end
  end

  def trigger_watch_dog

    # TODO: Check internal server status.

    ErrorLog.log('Watch Dog Timer', 'OK')
  end

  def trigger_watch_dog_and_reload
    trigger_watch_dog
    redirect_to root_root_path
  end

  def delete_error_log
    id = params[:id]
    if id.present? && id.to_i == DELETE_ALL_ID
      ErrorLog.all.delete_all
    else
      begin
        log = ErrorLog.find(id)
        log.delete
      rescue => e
        ErrorLog.log_exception(e)
      end
    end
  end

  def delete_error_log_and_reload
    delete_error_log
    redirect_to root_root_path
  end

  private
  # private

end
