class DcmSimStatsController < ApplicationController
  include NotifyFcm
  include SimStatsCommons

  def stats
    # Total data.
    @sim_stats = DcmSimStat.getAllLogArray
    @data_1, @data_2, @data_3 = gen_graph_data(@sim_stats)

    # Param.
    @chart_id = 'dcm_sim_stats'
    @mb_range, @mb_limit, @mb_ticks = DcmSimStatsController.get_range_limit_ticks
  end

  # Get used MB range params.
  #
  # @return Int, Int, Int[] Range, limit, and ticks.
  def self.get_range_limit_ticks
    range_max = 24000
    limit_mb = 20000
    ticks = []
    tick = 0
    while tick <= range_max
      ticks << tick
      tick += 2000
    end

    return range_max, limit_mb, ticks
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

    # Access to DCM server.
    status, month_used, yesterday_used = get_dcm_sim_stats

    # DEBUG LOG
#    puts "## status = #{status}"
#    puts "## month_used = #{month_used}"
#    puts "## yesterday_used = #{yesterday_used}"
#    render text: "DONE"
#    return

    res['is_sync_success'] = status

    # Store.
    is_y_ok, is_m_ok = store_sync_data(DcmSimStat, yesterday_used, month_used)
    res['is_yesterday_store_success'] = is_y_ok
    res['is_month_store_success'] = is_m_ok

    # Render HTML.
    html = get_sync_result(res)
    render text: html
  end

  # REST API.
  #
  def notify
    payload, code, msg, body = notify_latest_data(DcmSimStat, "dcm")

    # Render HTML
    ret = get_notify_result(payload, code, msg, body)
    render text: ret
  end

  private

    DCM_TOP_URL = 'https://www.nttdocomo.co.jp/mydocomo/data'
    INVALID_VALUE = -1

    # Get DCM SIM Stats.
    #
    # @return is_success, month_used_current, yesterday_used,
    def get_dcm_sim_stats
      require 'capybara/poltergeist'
      require 'uri'

      is_success = false

      # Set up Capybara.
      Capybara.register_driver :poltergeist do |app|
        Capybara::Poltergeist::Driver.new(app, { :js_errors => false, :timeout => 10000 })
      end
      session = Capybara::Session.new(:poltergeist)
      session.driver.headers = {
        'User-Agent' => 'Linux Mozilla'
      }

      # Get top page.
      session.visit(DCM_TOP_URL)

      login_url = nil
      is_success = get_with_retry {
        doc = Nokogiri::HTML.parse(session.html)
#        puts "## dcm top doc\n#{doc}"

        links = doc.css('a')
        links.each { |link|
          href = link.attributes['href'].value
          url = URI.unescape(href)
#          puts "## available url = #{url}"
          login_url = url if url.include?(DCM_TOP_URL)
        }

        !login_url.nil? # OK/NG of block.
      } # get_with_retry

#      puts "## Login URL = #{login_url}"

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      # Get login page.
      session.visit(login_url)

      next_button = nil
      is_success = get_with_retry {
        begin
          if session.has_text?(ENV['IN_DCM_NETWORK_INDICATOR'])
            # In DCM network.

            # TODO:

            pass_input = session.find('input#Di_Pass')
            pass_input.native.send_key(ENV['DCM_NETWORK_PIN'])
          else
            # In public network.
            id_input = session.find('input#Di_Uid')
            id_input.native.send_key(ENV['DCM_ID'])
          end
          next_button = session.find('input.button_submit.nextaction')

          true # OK of block.
        rescue Capybara::ElementNotFound => e
          puts "## login page (id) element not found, retry."

          false # NG of blck.
        end # begin
      } # get_with_retry

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      # Get next page.
      next_button.trigger('click')

      login_button = nil
      is_success = get_with_retry {
        begin
          if session.has_text?(ENV['IN_DCM_NETWORK_INDICATOR'])
            # In DCM network.

            # TODO:

            pass_input = session.find('input#Di_Pass')
            pass_input.native.send_key(ENV['DCM_NETWORK_PIN'])
          else
            # In public network.
            pass_input = session.find('input#Di_Pass')
            pass_input.native.send_key(ENV['DCM_PASS'])
          end
          login_button = session.find('input.button_submit.nextaction')

          true # OK of block.
        rescue Capybara::ElementNotFound => e
          puts "## login page (pass) element not found, retry."

          false # NG of blck.
        end # begin
      } # get_with_retry

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      # Get data page.
      login_button.trigger('click')

      month_used_current = nil
      yesterday_used = nil
      is_success = get_with_retry {
        doc = Nokogiri::HTML.parse(session.html)
#        puts doc.to_html

        month_used_current = doc.
            css('section#mydcm_page_data').
            css('div.card-data-block').
            css('div.in-data-use').
            css('span.card-t-number').
            text

        yesterday_used = doc.
            css('section#mydcm_data_3day').
            css('div#mydcm_data_3day-03').
            css('dl.mydcm_data_3day-03-02').
            css('span.card-t-ssnumber').
            text

        !month_used_current.empty? && !yesterday_used.empty? # OK/NG of block.
      } # get_with_retry

      return false, INVALID_VALUE, INVALID_VALUE if !is_success

      # Succeeded.
      puts "## Month Used Current = #{month_used_current} GB"
      puts "## Yesterday Used = #{yesterday_used} GB"

      # Convert from GB to MB.
      month_used_current = ((month_used_current.to_f) * 1000).to_i
      yesterday_used = ((yesterday_used.to_f) * 1000).to_i

      return is_success, month_used_current, yesterday_used
    end

    MAX_PARSE_RETRY_COUNT = 3
    RETRY_WAIT_SEC = 1

    def get_with_retry
      raise "No block given." if !block_given?

      count = 0
      is_ok = false
      while count < MAX_PARSE_RETRY_COUNT
        # Wait for AJAX.
        sleep RETRY_WAIT_SEC

        is_ok = yield

        break if is_ok

        count += 1
      end # while

      return is_ok
    end

  # private

end

