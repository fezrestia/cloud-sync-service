class ZeroSimUsagesController < ApplicationController

  def index
    @zero_sim_usages = ZeroSimUsage.all
  end

  def new
    @zero_sim_usage = ZeroSimUsage.new
  end

  def create
    @zero_sim_usage = ZeroSimUsage.new(zero_sim_usage_params)

    if @zero_sim_usage.save
      redirect_to "/zero_sim_usages/#{@zero_sim_usage.id}"
    else
      render 'new' # ZeroSimUsageController#new
    end
  end

  def show
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
  end

  def destroy
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
    @zero_sim_usage.destroy

    redirect_to zero_sim_usages_path
  end



private
  def zero_sim_usage_params
    params
        .require(:zero_sim_usage)
        .permit(:year, :month, :day, :day_used, :month_used_current)
  end

end

