module SimStats
  module SimStatsCommons extend self

    # Gen graph data.
    #
    # @total_stats SimStatBase[]
    # @return [[day, 2 month ago, last month, now] ...]
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
      graph_data_1 = convert_to_graph_data(logs_1)

      # Graph 2.
      logs_2 = total_stats.select { |log| (log.year == prev1_year) && (log.month == prev1_month) }
      graph_data_2 = convert_to_graph_data(logs_2)

      # Graph 3.
      logs_3 = total_stats.select { |log| (log.year == latest_year) && (log.month == latest_month) }
      graph_data_3 = convert_to_graph_data(logs_3)

      return convert_to_data_table(graph_data_1, graph_data_2, graph_data_3)
    end

    def convert_to_graph_data(logs)
      graph_data = [] # Result.

      first_day = logs.first.day
      1.upto(first_day - 1) { |d|
        graph_data << [d, nil]
      }

      last_val = 0
      logs.each { |log|
        day = log.day
        cur_val = log.month_used_current

        cur_val = 0 if cur_val.nil?

        if cur_val >= last_val
          graph_data << [day, cur_val]
          last_val = cur_val
        end
      } # logs.each

      return graph_data
    end

    # Convert to DataTable format as below.
    #
    # day | 2 Month Ago | Last Month | Now
    #
    def convert_to_data_table(last2MonthData, lastMonthData, nowData)
      table = []

      (1..31).each { |day|
        last2 = last2MonthData.find { |d, used| d == day }
        last2 = last2[1] if last2.present?

        last = lastMonthData.find { |d, used| d == day }
        last = last[1] if last.present?

        now = nowData.find { |d, used| d == day }
        now = now[1] if now.present?

        table << [day, last2, last, now]
      }

      return table
    end

    # Day ticks. [1, 2, 3, ... 30, 31].
    #
    def gen_day_ticks
      ticks = []
      (1..31).each { |day|
        ticks << day
      }
      return ticks
    end

  end
end

