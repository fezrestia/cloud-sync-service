class NuroSimStatsController < ApplicationController
  include NotifyFcm
  include SimStatsCommons

  def stats
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

    if status
      # Yesterday log.
      y_log = NuroSimStat.get_from_date(Time.zone.now.yesterday)
      y_log.day_used = yesterday_used
      res['is_yesterday_store_success'] = y_log.store

      # Today log.
      t_log = NuroSimStat.get_from_date(Time.zone.now)
      t_log.month_used_current = month_used
      res['is_month_store_success'] = t_log.store
    end

    # Return JSON.
    render json: res
  end

  # REST API.
  #
  def notify
    # Today log.
    t_log = NuroSimStat.get_from_date(Time.zone.now)

    # Payload.
    datamap = {}
    datamap["app"] = "sim-stats"
    datamap["nuro_month_used_current_mb"] = t_log.month_used_current

    datares = NotifyFcm.notifyToDeviceData(datamap)

    code = datares.nil? ? 'N/A' : datares.code
    message = datares.nil? ? 'N/A' : datares.message
    body = datares.nil? ? 'N/A' : datares.body

    ret = <<-"RET"
<pre>
API: notify

DATA: #{datamap}

CODE: #{code}
MSG: #{message}
BODY: #{body}
</pre>
    RET

    # Return JSON.
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

