class ZeroSimStatsController < ApplicationController

  def stats
    # Total data.
    all_log_hash = ZeroSimStat.getAllLogHash
    @zero_sim_stats = [] # output
    @graph_data_1 = [] # Output
    @graph_data_2 = [] # Output
    @graph_data_3 = [] # Output

    # Parse.
    available_years = []
    for year in all_log_hash.keys
      y_int = year.delete('y').to_i
      available_years.push(y_int)
    end
    available_years.sort!
    available_year_vs_month_list_hash = {}
    for year in available_years
      y_key = "y#{year}"
      available_months = []
      for month in all_log_hash[y_key].keys
        m_int = month.delete('m').to_i
        available_months.push(m_int)
      end
      available_months.sort!
      available_year_vs_month_list_hash[year] = available_months
    end

    # Generate ZeroSimStats list.
    for y in available_years
      for m in available_year_vs_month_list_hash[y]
        start_date = Date.new(y, m, 1)
        end_date = Date.new(y, m, -1)
        for date in start_date..end_date
          log = ZeroSimStat.getLogFromHash(date.year, date.month, date.day, all_log_hash)
          if !log.day_used.nil? || !log.month_used_current.nil?
            @zero_sim_stats.push(log)
          end
        end
      end
    end

    # Graph data.
    latest = @zero_sim_stats.last
    if !latest.nil?
      latest_year = latest.year
      latest_month = latest.month
    else
      latest_year = 2000
      latest_month = 1
    end

    prev1_year = latest_year
    prev1_month = latest_month -1
    if prev1_month <= 0
      prev1_year -= 1
      prev1_month += 12
    end

    prev2_year = latest_year
    prev2_month = latest_month -2
    if prev2_month <= 0
      prev2_year -= 1
      prev2_month += 12
    end

    # Graph 1.
    for log in @zero_sim_stats
      if (log.year == prev2_year) && (log.month == prev2_month)
        @graph_data_1.push(["#{log.day}", "#{log.month_used_current}"])
      end
    end

    # Graph 2.
    for log in @zero_sim_stats
      if (log.year == prev1_year) && (log.month == prev1_month)
        @graph_data_2.push(["#{log.day}", "#{log.month_used_current}"])
      end
    end

    # Graph 3.
    for log in @zero_sim_stats
      if (log.year == latest_year) && (log.month == latest_month)
        @graph_data_3.push(["#{log.day}", "#{log.month_used_current}"])
      end
    end
  end

  # REST API.
  #
  def debug
    #### Load current env log
    log_file_path = "#{Rails.root.to_s}/log/#{ENV['RAILS_ENV']}.log"
    ret = "DEFAULT"
    File.open(log_file_path, 'r') do |file|
      ret = file.read
    end
    render text: ret
  end

  # REST API.
  #
  def sync
    # Return log string.
    ret = "API sync<br><br>"

    # Get 0 SIM stats.
    zero_sim_stats = get_zero_sim_stats
    yesterday_used_mb = zero_sim_stats[:yesterday_used_mb]
    month_used_current_mb = zero_sim_stats[:month_used_current_mb]

    # Yesterday log.
    yesterday = Time.zone.now.yesterday
    y_log = ZeroSimStat.get(yesterday.year, yesterday.month, yesterday.day)
    y_log.day_used = yesterday_used_mb
    is_success = y_log.store
    if is_success
      ret += "    Yesterday Log: SUCCESS<br>"
    else
      ret += "    Yesterday Log: FAILED<br>"
    end

    ret += "<br>"

    # Today log.
    today = Time.zone.now
    t_log = ZeroSimStat.get(today.year, today.month, today.day)
    t_log.month_used_current = month_used_current_mb
    is_success = t_log.store
    if is_success
      ret += "    Today Log: SUCCESS<br>"
    else
      ret += "    Today Log: FAILED<br>"
    end

    # Return string.
    render text: ret
  end

  # REST API.
  #
  def notify
    # Get 0 SIM stats.
    zero_sim_stats = get_zero_sim_stats

    # Do notify.
    ret = ''
# Disable remote notification.
#    resm = notifyToDeviceMsg(
#        "0 SIM Stats",
#        "Current : #{zero_sim_stats[:month_used_current_mb]} MB/month")
#    ret += "Msg:<br>    CODE:#{resm.code}<br>    MSG:#{resm.message}<br>    BODY:#{resm.body}"
#    ret += "<br><br>"

    # Payload.
    datamap = {}
    datamap["app"] = "zero-sim-stats"
    datamap["zerosim_month_used_current_mb"] = zero_sim_stats[:month_used_current_mb]
    datamap["nuro_month_used_current_mb"] = rand(0..2000) # TODO:
    datamap["docomo_month_used_current_mb"] = rand(0..20000) # TODO:

    resd = notifyToDeviceData(datamap)
    ret += "Data:<br>    CODE:#{resd.code}<br>    MSG:#{resd.message}<br>    BODY:#{resd.body}"

    # Return string.
    render text: ret
  end

  private

    # Get 0 SIM Stats.
    #
    # return hash
    #     :yesterday_used_mb
    #     :month_used_current_mb
    #
    def get_zero_sim_stats
      require 'mechanize'

      # Get data from so-net web.
      agent = Mechanize.new
      agent.user_agent_alias = 'Linux Mozilla'

      #TODO: Consider server down.

      # Login.
      login_page = agent.get('https://www.so-net.ne.jp/retail/u/')
      login_form = login_page.form_with(:name => 'Login')
      login_form.IDToken1 = ENV['ZERO_SIM_NUMBER']
      login_form.IDToken2 = ENV['ZERO_SIM_PASS']

      # Top page.
      top_page = agent.submit(login_form)

      # Stats page.
      stats_form = top_page.form_with(:name => 'userUsageActionForm')
      stats_page = agent.submit(stats_form)

      # Parse stats.
      stats_list = stats_page.search('//dl[@class="useConditionDisplay"]')
      yesterday_used_mb = stats_list.search('dd')[2].text.to_i
      month_used_current_mb = stats_list.search('dd')[0].text.to_i

      ret = {
          :yesterday_used_mb => stats_list.search('dd')[2].text.to_i,
          :month_used_current_mb => stats_list.search('dd')[0].text.to_i
      }

      return ret
    end

    # Request to notify device via Notification message.
    #
    # @titleStr Title string
    # @contentStr Content string
    # @data_hash Data notification key/value.
    # @return Response
    #
    def notifyToDeviceMsg(titleStr, contentStr)
      client_info = ClientInfo.get_primary
      fcm_token = client_info.fcm_token
      return nil if fcm_token.nil?

      payload = "{
          \"notification\": {
              \"title\": \"#{titleStr}\",
              \"text\": \"#{contentStr}\"
          },
          \"to\": \"#{fcm_token}\"
      }"

      response = doNotify(payload)

      return response
    end

    # Request to nofity device via Data message.
    #
    # @data_hash
    # @return Response
    #
    def notifyToDeviceData(data_hash)
      client_info = ClientInfo.get_primary
      fcm_token = client_info.fcm_token
      return nil if fcm_token.nil?

      data_str = ''
      for key in data_hash.keys
        data_str += "\"#{key}\": \"#{data_hash[key]}\","
      end

      payload = "{
          \"data\": {
              #{data_str}
          },
          \"to\": \"#{fcm_token}\"
      }"

      response = doNotify(payload)

      return response
    end

    def doNotify(payload)
      require 'net/https'

      uri = URI.parse("https://fcm.googleapis.com/fcm/send")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "key=#{ENV['FCM_TOKEN']}"

      request.body = payload

      response = http.request(request)

      return response
    end

end

