class NuroSimStatsController < ApplicationController
  include NotifyFcm
  include SimStatsCommons

  def stats
    # Total data.
    @sim_stats = NuroSimStat.getAllLogArray
    @graph_data_1, @graph_data_2, @graph_data_3 = gen_graph_data(@sim_stats)

    # Param.
    @limit_mb = 2000
    @v_max = 2400
    tick = 0
    @v_tick = []
    while tick <= @v_max
      @v_tick << tick
      tick += 200
    end
  end

  # REST API.
  #
  def debug
    render text: 'DEBUG API'
  end

  # REST API.
  #
  def sync
    # Response JSON.
    res = {}

    # Access to Nuro server.
    status, month_used, yesterday_used = get_nuro_sim_stats
    res['is_sync_success'] = status

    # Store.
    is_y_ok, is_m_ok = store_sync_data(NuroSimStat, yesterday_used, month_used)
    res['is_yesterday_store_success'] = is_y_ok
    res['is_month_store_success'] = is_m_ok

    # Render HTML.
    html = get_sync_result(res)
    render text: html
  end

  # REST API.
  #
  def notify
    payload, code, msg, body = notify_latest_data(NuroSimStat, "nuro")

    # Render HTML
    ret = get_notify_result(payload, code, msg, body)
    render text: ret
  end

  private

    NURO_LOGIN_PAGE = 'https://mobile.nuro.jp/mobile_contract/u/login/'
    INVALID_VALUE = -1

    # Get Nuro SIM Stats.
    #
    # @return
    def get_nuro_sim_stats
      require 'capybara_wrapper'

      scraper = CapybaraWrapper.new

      is_success = false
      month_used = INVALID_VALUE
      day_used = INVALID_VALUE

      # Login.
      scraper.get(NURO_LOGIN_PAGE)
      is_success = scraper.wait_for {
        scraper.input_to_id(ENV['NURO_ID'], 'input#simNumber')
        scraper.input_to_id(ENV['NURO_PASS'], 'input#simPassword')
        scraper.click_on_id('input#simSubmit')
      }

      return is_success, month_used, day_used if !is_success

      is_success = scraper.wait_for {
        month_elements = [
            'div#main',
            'div.container',
            'section',
            'div.indexBox',
            'div.float',
            'div.block.right.zyokyo',
            'ul.zyokyoBlock',
            'li',
            'ul',
            'li',
            'p.data',
            'span.yen',
        ]
        month_used = scraper.get_text(month_elements)

        day_elements = [
            'div#main',
            'div.container',
            'section',
            'div.indexBox',
            'div.float',
            'div.block.right.zyokyo',
            'ul.zyokyoBlock',
            ['p.data', 4],
            'span.yen',
        ]
        day_used = scraper.get_text(day_elements)
      } # scraper.wait_for

      puts "## month_used = #{month_used}"
      puts "## day_used = #{day_used}"

      return is_success, month_used.delete(',').to_i, day_used.delete(',').to_i
    end

  # private

end

