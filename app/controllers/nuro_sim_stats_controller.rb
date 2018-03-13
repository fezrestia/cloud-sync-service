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
    # Response JSON.
    res = {}

    res['is_sync_success'] = false

    # Return JSON.
    render json: res
  end

  # REST API.
  #
  def notify
    # Response JSON.
    res = {}

    res['code'] = 200

    # Return JSON.
    render json: res
  end

  private

    # Get Nuro SIM Stats.
    #
    # @return
    def get_nuro_sim_stats
    end

  # private

end

