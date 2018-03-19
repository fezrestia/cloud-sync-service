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
    # Response JSON.
    res = {}

    # Access to ZEROSIM server.
    zero_sim_stats = get_zero_sim_stats
    yesterday_used_mb = zero_sim_stats[:yesterday_used_mb]
    month_used_current_mb = zero_sim_stats[:month_used_current_mb]
    res['is_sync_success'] = yesterday_used_mb.present? && month_used_current_mb.present?

    # Store.
    is_y_ok, is_m_ok = store_sync_data(ZeroSimStat, yesterday_used_mb, month_used_current_mb)
    res['is_yesterday_store_success'] = is_y_ok
    res['is_month_store_success'] = is_m_ok

    # Render HTML.
    html = get_sync_result(res)
    render text: html
  end

  # REST API.
  #
  def notify
    payload, code, msg, body = notify_latest_data(ZeroSimStat, "zerosim")

    # Render HTML
    ret = get_notify_result(payload, code, msg, body)
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

