class ZeroSimUsagesController < ApplicationController

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

    # Generate ZeroSimUsage list.
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

  def index
    @zero_sim_usages = ZeroSimUsage.all

    # Graph data.
    latest = ZeroSimUsage.last
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

    data_1 = ZeroSimUsage.where(
        year: prev2_year,
        month: prev2_month)
    @graph_data_1 = []
    for log in data_1
      date = "#{log.day}"
      @graph_data_1.push(["#{date}", "#{log.month_used_current}"])
    end

    data_2 = ZeroSimUsage.where(
        year: prev1_year,
        month: prev1_month)
    @graph_data_2 = []
    for log in data_2
      date = "#{log.day}"
      @graph_data_2.push(["#{date}", "#{log.month_used_current}"])
    end

    data_3 = ZeroSimUsage.where(
        year: latest_year,
        month: latest_month)
    @graph_data_3 = []
    for log in data_3
      date = "#{log.day}"
      @graph_data_3.push(["#{date}", "#{log.month_used_current}"])
    end
  end

  def new
    @zero_sim_usage = ZeroSimUsage.new
  end

  def create
    @zero_sim_usage = ZeroSimUsage.new(zero_sim_usage_params)

    if @zero_sim_usage.save
      redirect_to "/zero_sim_usages/#{@zero_sim_usage.id}"
    else
      render 'new' # ZeroSimUsageController#new
    end
  end

  def show
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
  end

  def edit
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
  end

  def update
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
    if @zero_sim_usage.update_attributes(zero_sim_usage_params)
      # Update succeeded.
      redirect_to zero_sim_usage_path(@zero_sim_usage.id)
    else
      # Update failed.
      render 'edit' # ZeroSimUsageController#edit
    end
  end

  def destroy
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
    @zero_sim_usage.destroy

    redirect_to zero_sim_usages_path
  end

  # REST API.
  #
  def debug
    render text: 'DEBUG'



=begin Load log fron Firebase Data Base.
    # Path.
    today = Time.zone.now
    root_path = 'https://cloud-sync-service.firebaseio.com/zero-sim-usage/logs/'
    file_path = "y#{today.year}/m#{today.month}"
    ext = '.json'
    full_path = root_path + file_path + ext
    puts "PATH=#{full_path}"

    response = httpsGet(full_path)

    # JSON.
    jsonHash = JSON.load(response.body)

    render text: "PATH=#{full_path} / CODE=#{response.code} / BODY=#{response.body}"
=end



=begin Dump ALL logs to Firebase Data Base.
    # Post to firebase db.
    require 'net/http'
    require 'uri'

    # Total response.
    ret = "RESULT:\n"

    # All log.
    logs = ZeroSimUsage.all

    for log in logs
      # Path.
      root_path = 'https://cloud-sync-service.firebaseio.com/zero-sim-usage/logs/'
      file_path = "y#{log.year}/m#{log.month}/d#{log.day}"
      ext = '.json'
      full_path = root_path + file_path + ext

      # Data.
      data = {}
      data['day_used'] = log.day_used
      data['month_used_current'] = log.month_used_current
      json = JSON.generate(data)

      # HTTP.
      response = httpsPut(full_path, json)

      # Web API return.
      ret += "    CODE=#{response.code} / BODY=#{response.body}\n"
    end

#    render text: ret
    render text: 'DONE'
=end



=begin
    #### Lod production.log

    log_file_path = "#{Rails.root.to_s}/log/production.log"
    ret = "DEFAULT"

    File.open(log_file_path, 'r') do |file|
      ret = file.read
    end

    render text: ret
=end
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
    datamap["month_used_current"] = zero_sim_stats[:month_used_current_mb]

    resd = notifyToDeviceData(datamap)
    ret += "Data:<br>    CODE:#{resd.code}<br>    MSG:#{resd.message}<br>    BODY:#{resd.body}"

    # Return string.
    render text: ret
  end

private
  def zero_sim_usage_params
    params
        .require(:zero_sim_usage)
        .permit(:year, :month, :day, :day_used, :month_used_current)
  end

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

    # Usage page.
    usage_form = top_page.form_with(:name => 'userUsageActionForm')
    usage_page = agent.submit(usage_form)

    # Parse usage.
    usage_list = usage_page.search('//dl[@class="useConditionDisplay"]')
    yesterday_used_mb = usage_list.search('dd')[2].text.to_i
    month_used_current_mb = usage_list.search('dd')[0].text.to_i

    ret = {
        :yesterday_used_mb => usage_list.search('dd')[2].text.to_i,
        :month_used_current_mb => usage_list.search('dd')[0].text.to_i
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
    payload = "{
        \"notification\": {
            \"title\": \"#{titleStr}\",
            \"text\": \"#{contentStr}\"
        },
        \"to\": \"dvbFOm_OuTc:APA91bGkjLfgGdrKMtVHZDWtI4dIEKnYUwzNAUqxKNmZpfzrc-aNfiiDH8Se_u_z1fEzv_z0zmhfLeSrylmLZq8tXMnyw2U1bCgGR-jX4jXMmZN7J2UTPA7qQtBp6Le76eH6GxtVmd5j\"
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
    data_str = ''
    for key in data_hash.keys
      data_str += "\"#{key}\": \"#{data_hash[key]}\","
    end

    payload = "{
        \"data\": {
            #{data_str}
        },
        \"to\": \"dvbFOm_OuTc:APA91bGkjLfgGdrKMtVHZDWtI4dIEKnYUwzNAUqxKNmZpfzrc-aNfiiDH8Se_u_z1fEzv_z0zmhfLeSrylmLZq8tXMnyw2U1bCgGR-jX4jXMmZN7J2UTPA7qQtBp6Le76eH6GxtVmd5j\"
    }"

    response = doNotify(payload)

    return response
  end

  private

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

