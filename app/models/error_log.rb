class ErrorLog < ApplicationRecord

  def self.log_exception(exception)
    log(exception.message, exception.backtrace.join("\n"))
  end

  def self.log(title, body)
    log = ErrorLog.new( {
        :title => title,
        :body => body,
        :when => Time.now.utc,
    } )
    log.save!
  end

end
