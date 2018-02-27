class ZeroSimStatsController < ApplicationController
  include NotifyFcm

  def stats
    # Total data.
    @zero_sim_stats = ZeroSimStat.getAllLogArray

    @graph_data_1 = []
    @graph_data_2 = []
    @graph_data_3 = []

    # Sort year/month/day data.
    @zero_sim_stats.sort_by! { |log| log.day }
    @zero_sim_stats.sort_by! { |log| log.month }
    @zero_sim_stats.sort_by! { |log| log.year }

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
    logs_1 = @zero_sim_stats.select { |log| (log.year == prev2_year) && (log.month == prev2_month) }
    @graph_data_1 = logs_1.map { |log| ["#{log.day}", "#{log.month_used_current}"] }

    # Graph 2.
    logs_2 = @zero_sim_stats.select { |log| (log.year == prev1_year) && (log.month == prev1_month) }
    @graph_data_2 = logs_2.map { |log| ["#{log.day}", "#{log.month_used_current}"] }

    # Graph 3.
    logs_3 = @zero_sim_stats.select { |log| (log.year == latest_year) && (log.month == latest_month) }
    @graph_data_3 = logs_3.map { |log| ["#{log.day}", "#{log.month_used_current}"] }

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
#    resm = NotifyFcm.notifyToDeviceMsg(
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

    resd = NotifyFcm.notifyToDeviceData(datamap)
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

  # private

end

