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

  def edit
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
  end

  def update
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
    if @zero_sim_usage.update_attributes(zero_sim_usage_params)
      # Update succeeded.
      redirect_to zero_sim_usage_path(@zero_sim_usage.id)
    else
      # Update failed.
      render 'edit' # ZeroSimUsageController#edit
    end
  end

  def destroy
    @zero_sim_usage = ZeroSimUsage.find(params[:id])
    @zero_sim_usage.destroy

    redirect_to zero_sim_usages_path
  end

  # REST API.
  #
  def debug
    log_file_path = "#{Rails.root.to_s}/log/production.log"
    ret = "DEFAULT"

    File.open(log_file_path, 'r') do |file|
      ret = file.read
    end

    render text: ret
  end

  # REST API.
  #
  def sync
    require 'mechanize'

    # Return log string.
    ret = "API sync\n"

    # Get data from so-net web.
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Mozilla'

    #TODO: Consider server down.
    # Login.
    login_page = agent.get('https://www.so-net.ne.jp/retail/u/')
    login_form = login_page.form_with(:name => 'Login')
    login_form.IDToken1 = ENV['ZERO_SIM_NUMBER']
    login_form.IDToken2 = ENV['ZERO_SIM_PASS']
    # Top page.
    top_page = agent.submit(login_form)
    # Usage page.
    usage_form = top_page.form_with(:name => 'userUsageActionForm')
    usage_page = agent.submit(usage_form)
    # Parse usage.
    usage_list = usage_page.search('//dl[@class="useConditionDisplay"]')
    yesterday_used_mb = usage_list.search('dd')[2].text.to_i
    month_used_current_mb = usage_list.search('dd')[0].text.to_i

    # Yesterday log.
    yesterday = Time.zone.now.yesterday
    ret += "Yesterday = #{yesterday}\n"
    yesterday_log = ZeroSimUsage.find_by(
        year: yesterday.year,
        month: yesterday.month,
        day: yesterday.day)
    if yesterday_log.nil?
      ret += "    New record is created.\n"
      yesterday_log = ZeroSimUsage.new
      yesterday_log.year = yesterday.year
      yesterday_log.month = yesterday.month
      yesterday_log.day = yesterday.day
    else
      ret += "    Record is already existing.\n"
    end
    yesterday_log.day_used = yesterday_used_mb
    ret += "    Data = #{yesterday_used_mb}\n"
    if yesterday_log.save
      ret += "    Log.save SUCCESS\n"
    else
      ret += "    Log.save FAILED\n    #{yesterday_log.errors.full_messages}\n"
    end

    # Today log.
    today = Time.zone.now
    ret += "Today = #{today}\n"
    today_log = ZeroSimUsage.find_by(
        year: today.year,
        month: today.month,
        day: today.day)
    if today_log.nil?
      ret += "    New record is created.\n"
      today_log = ZeroSimUsage.new
      today_log.year = today.year
      today_log.month = today.month
      today_log.day = today.day
    else
      ret += "    Record is already existing.\n"
    end
    today_log.month_used_current = month_used_current_mb
    ret += "    Data = #{month_used_current_mb}\n"
    if today_log.save
      ret += "    Log.save SUCCESS\n"
    else
      ret += "    Log.save FAILED\n    #{today_log.errors.full_messages}\n"
    end

    # Return string.
    render text: ret
  end

private
  def zero_sim_usage_params
    params
        .require(:zero_sim_usage)
        .permit(:year, :month, :day, :day_used, :month_used_current)
  end

end

