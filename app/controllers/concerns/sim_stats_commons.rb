module SimStatsCommons extend self

  # Gen 3 graph data lines.
  #
  # @total_stats SimStatBase[]
  # @return [[day, month_used_current] ...] x3
  def gen_graph_data(total_stats)
    graph_data_1 = []
    graph_data_2 = []
    graph_data_3 = []

    # Sort year/month/day data.
    total_stats.sort_by! { |log| log.day }
    total_stats.sort_by! { |log| log.month }
    total_stats.sort_by! { |log| log.year }

    # Graph data.
    latest = total_stats.last
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
    logs_1 = total_stats.select { |log| (log.year == prev2_year) && (log.month == prev2_month) }
    graph_data_1 = logs_1.map { |log| ["#{log.day}", "#{log.month_used_current}"] }

    # Graph 2.
    logs_2 = total_stats.select { |log| (log.year == prev1_year) && (log.month == prev1_month) }
    graph_data_2 = logs_2.map { |log| ["#{log.day}", "#{log.month_used_current}"] }

    # Graph 3.
    logs_3 = total_stats.select { |log| (log.year == latest_year) && (log.month == latest_month) }
    graph_data_3 = logs_3.map { |log| ["#{log.day}", "#{log.month_used_current}"] }

    return graph_data_1, graph_data_2, graph_data_3
  end

  # Store sync data and return response.
  #
  # @stat_base StatBase Storage class.
  # @yesterday_used Integer Used MB.
  # @month_used Integer Used MB.
  # @return Boolean, Boolean Store is succeeded or not.(yesterday, month).
  def store_sync_data(stat_base, yesterday_used, month_used)
      # Yesterday log.
      y_log = stat_base.get_from_date(Time.zone.now.yesterday)
      y_log.day_used = yesterday_used
      is_y_ok = y_log.store

      # Today log.
      t_log = stat_base.get_from_date(Time.zone.now)
      t_log.month_used_current = month_used
      is_m_ok = t_log.store

      return is_y_ok, is_m_ok
  end

  # Get render HTML from result hash.
  #
  # @hash Hash Sync result.
  # @return String HTML pre-format string.
  def get_sync_result(hash)
    ret = <<-"RET"
<pre>
API: sync

SYNC SUCCESS: #{hash['is_sync_success']}

YESTERDAY LOG: #{hash['is_yesterday_store_success']}
MONTH LOG: #{hash['is_month_store_success']}
</pre>
    RET

    return ret
  end

  # Notify latest log to device.
  #
  # @stat_base StatBase Storage class.
  # @service_key Service identifier included in payload key. (e.g. zerosim, nuro, or dcm)
  # @return Hash, String, String, String Payload, Code, Message, Body.
  def notify_latest_data(stat_base, service_key)
    # Latest log.
    t_log = stat_base.get_from_date(Time.zone.now)

    # Payload.
    payload = {}
    payload["app"] = "sim-stats"
    payload["#{service_key}_month_used_current_mb"] = t_log.month_used_current

    res = NotifyFcm.notifyToDeviceData(payload)

    # Response.
    code = res.nil? ? 'N/A' : res.code
    msg = res.nil? ? 'N/A' : res.message
    body = res.nil? ? 'N/A' : res.body

    return payload, code, msg, body
  end

  # Get render HTML from notify result.
  #
  # @payload Hash Notify payload.
  # @code String Response code.
  # @msg String Response message.
  # @body String Response body.
  # @return String HTML pre-format string.
  def get_notify_result(payload, code, msg, body)
    ret = <<-"RET"
<pre>
API: notify

PAYLOAD: #{payload}

CODE: #{code}
MSG: #{msg}
BODY: #{body}
</pre>
    RET

    return ret
  end

end

