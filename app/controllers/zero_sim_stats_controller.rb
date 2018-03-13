class ZeroSimStatsController < ApplicationController
  include NotifyFcm
  include SimStatsCommons

  def stats
    # Total data.
    @zero_sim_stats = ZeroSimStat.getAllLogArray
    @graph_data_1, @graph_data_2, @graph_data_3 = gen_graph_data(@zero_sim_stats)
  end

  # REST API.
  #
  def debug
    render plain: 'DEBUG API'
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
    y_log = ZeroSimStat.get_from_date(Time.zone.now.yesterday)
    y_log.day_used = yesterday_used_mb
    is_success = y_log.store
    if is_success
      ret += "    Yesterday Log: SUCCESS<br>"
    else
      ret += "    Yesterday Log: FAILED<br>"
    end

    ret += "<br>"

    # Today log.
    t_log = ZeroSimStat.get_from_date(Time.zone.now)
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

    # Payload.
    datamap = {}
    datamap["app"] = "sim-stats"
    datamap["zerosim_month_used_current_mb"] = zero_sim_stats[:month_used_current_mb]

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

