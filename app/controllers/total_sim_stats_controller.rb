class TotalSimStatsController < ApplicationController
  include SimStatsCommons

  def latest
    @dcm_chart_id = 'dcm_sim_stats'
    @nuro_chart_id = 'nuro_sim_stats'
    @zero_chart_id = 'zero_sim_stats'

    # Total data.
    @dcm_data_1, @dcm_data_2, @dcm_data_3 = gen_graph_data(DcmSimStat.getAllLogArray)
    @nuro_data_1, @nuro_data_2, @nuro_data_3 = gen_graph_data(NuroSimStat.getAllLogArray)
    @zero_data_1, @zero_data_2, @zero_data_3 = gen_graph_data(ZeroSimStat.getAllLogArray)

    # Total graph scale range.
    @dcm_mb_range, @dcm_mb_limit, @dcm_mb_ticks = DcmSimStatsController.get_range_limit_ticks
    @nuro_mb_range, @nuro_mb_limit, @nuro_mb_ticks = NuroSimStatsController.get_range_limit_ticks
    @zero_mb_range, @zero_mb_limit, @zero_mb_ticks = ZeroSimStatsController.get_range_limit_ticks
  end

end

