module SimStats
  class TotalSimStatsController < ApplicationController

    include SimStats::SimStatsCommons

    def latest
      # Total data.
      @dcm_data_table = gen_graph_data(DcmSimStat.getAllLogArray)
      @nuro_data_table = gen_graph_data(NuroSimStat.getAllLogArray)
      @zerosim_data_table = gen_graph_data(ZeroSimStat.getAllLogArray)

      # Total graph scale range.
      @dcm_mb_range, @dcm_mb_limit, @dcm_mb_ticks = DcmSimStatsController.get_range_limit_ticks
      @nuro_mb_range, @nuro_mb_limit, @nuro_mb_ticks = NuroSimStatsController.get_range_limit_ticks
      @zerosim_mb_range, @zerosim_mb_limit, @zerosim_mb_ticks = ZeroSimStatsController.get_range_limit_ticks
      @day_ticks = gen_day_ticks
    end

  end
end

