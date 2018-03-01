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
  end

  # REST API.
  #
  def notify
  end

  private

    # Get Nuro SIM Stats.
    #
    # @return
    def get_nuro_sim_stats
    end

  # private

end

