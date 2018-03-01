class NuroSimStat < SimStatBase

  def self.get_firebase_db_root
    return 'https://cloud-sync-service.firebaseio.com/nuro-sim-usage/logs/'
  end

  def self.create_instance(year, month, day, day_used, month_used_current)
    return NuroSimStat.new(year, month, day, day_used, month_used_current)
  end

end

