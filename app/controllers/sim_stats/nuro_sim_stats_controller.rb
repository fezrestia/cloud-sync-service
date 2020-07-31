module SimStats
  class NuroSimStatsController < ApplicationController

    include SimStats::SimStatsCommons

    def stats
      # Total data.
      @sim_stats = NuroSimStat.getAllLogArray

      @data_table = gen_graph_data(@sim_stats)

      # Param.
      @mb_range, @mb_limit, @mb_ticks = NuroSimStatsController.get_range_limit_ticks
      @day_ticks = gen_day_ticks
    end

    # Get used MB range params.
    #
    # @return Int, Int, Int[] Range, limit, and ticks.
    def self.get_range_limit_ticks
      range_max = 2400
      limit_mb = 2000
      ticks = []
      tick = 0
      while tick <= range_max
        ticks << tick
        tick += 200
      end

      return range_max, limit_mb, ticks
    end

    private
    # private

  end
end

