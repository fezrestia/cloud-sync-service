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



end

