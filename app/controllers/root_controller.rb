class RootController < ApplicationController

  def root
    @error_logs = ErrorLog.all.load
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
    begin
      log = ErrorLog.find(id)
      log.delete
    rescue => e
      ErrorLog.log_exception(e)
    end
  end

  def delete_error_log_and_reload
    delete_error_log
    redirect_to root_root_path
  end

  private
  # private

end
