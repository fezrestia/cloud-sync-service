require "#{Rails.root}/app/models/zero_sim_usage"

class Tasks::ZeroSimUsage::SyncZeroSimUsageFromServerToDatabase
  def self.execute

    # Test
    log = ZeroSimUsage.new
    log.year = 2000
    log.month = 1
    log.day = 31
    log.day_used = 10
    log.month_used_current = 100
    log.save

  end
end

