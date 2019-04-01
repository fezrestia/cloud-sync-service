class DcmSimStatsController < ApplicationController
  include NotifyFcm
  include SimStatsCommons

  require 'web-parser/dcm_web_parser.rb'

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
    dcm_web = DcmWebParser.new(
        ENV['IN_DCM_NETWORK_INDICATOR'],
        ENV['DCM_NETWORK_PIN'],
        ENV['DCM_ID'],
        ENV['DCM_PASS'])
    status, month_used_mb, yesterday_used_mb = dcm_web.get_data_from_web

    # DEBUG LOG
#    puts "## status = #{status}"
#    puts "## month_used_mb = #{month_used_mb}"
#    puts "## yesterday_used_mb = #{yesterday_used_mb}"
#    render text: "DONE"
#    return

    res['is_sync_success'] = status

    # Store.
    is_y_ok, is_m_ok = store_sync_data(DcmSimStat, yesterday_used_mb, month_used_mb)
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
  # private

end

