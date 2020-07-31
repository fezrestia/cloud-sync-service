module SimStats
  class DcmSimStatsController < ApplicationController

    include SimStats::SimStatsCommons

    def stats
      # Total data.
      @sim_stats = DcmSimStat.getAllLogArray

      @data_table = gen_graph_data(@sim_stats)

      # Param.
      @mb_range, @mb_limit, @mb_ticks = DcmSimStatsController.get_range_limit_ticks
      @day_ticks = gen_day_ticks
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

    private
    # private

  end
end

