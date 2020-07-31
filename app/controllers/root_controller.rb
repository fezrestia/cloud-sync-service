class RootController < ApplicationController

  def root
    puts "## RootController.root()"



  end

  def current_log
    log_file_path = "#{Rails.root.to_s}/log/#{ENV['RAILS_ENV']}.log"

    text = "NO LOG"
    File.open(log_file_path, 'r') { |file|
      text = file.read
    }

    html = <<-"HTML"
<pre>
  #{text}
</pre>
    HTML

    render html: html.html_safe
  end


end
