class ZeroSimStat
  include Https

  require 'net/http'
  require 'uri'

  attr_reader :year, :month, :day, :day_used, :month_used_current, :firebase_db_root
  attr_writer :day_used, :month_used_current

  ## Constants.
  FIREBASE_DB_ROOT = 'https://cloud-sync-service.firebaseio.com/zero-sim-usage/logs/'

  # CONSTRUCTOR
  #
  # @year
  # @month
  # @day
  # @day_used
  # @month_used_current
  #
  def initialize(year, month, day, day_used, month_used_current)
    @year = year
    @month = month
    @day = day
    @day_used = day_used
    @month_used_current = month_used_current
  end

  # Get available all log.
  #
  # @return array of ZeroSimStats
  #
  def self.getAllLogArray
    # Path.
    ext = '.json'
    full_path = FIREBASE_DB_ROOT + ext

    # HTTP.
    response = Https.get(full_path)

    # JSON.
    json_hash = JSON.load(response.body)

    # Parse JSON to ZeroSimStats array.
    all_logs = []
    # Year.
    for year in json_hash.keys
      # Month.
      for month in json_hash[year].keys
        # Day.
        for day in json_hash[year][month].keys
          # Data.
          y_int = year.delete('y').to_i
          m_int = month.delete('m').to_i
          d_int = day.delete('d').to_i
          log = getLogFromHash(y_int, m_int, d_int, json_hash)

          all_logs.push(log)
        end
      end
    end

    return all_logs
  end

  # Get available all log.
  #
  # @return Hash of all log.
  #
  def self.getAllLogHash
    # Path.
    ext = '.json'
    full_path = FIREBASE_DB_ROOT + ext

    # HTTP.
    response = Https.get(full_path)

    # JSON.
    jsonHash = JSON.load(response.body)

    return jsonHash
  end

  # Get 1 log from hash.
  #
  # @year
  # @month
  # @day
  # @hash
  # @return
  #
  def self.getLogFromHash(year, month, day, hash)
    y_key = "y#{year}"
    m_key = "m#{month}"
    d_key = "d#{day}"
    if !hash[y_key].nil? && !hash[y_key][m_key].nil? && !hash[y_key][m_key][d_key].nil?
      day_used = hash[y_key][m_key][d_key]['day_used']
      month_used_current = hash[y_key][m_key][d_key]['month_used_current']
    end

    log = ZeroSimStat.new(year, month, day, day_used, month_used_current)

    return log
  end

  # Get 1 log.
  #
  # @year
  # @month
  # @day
  # @return ZeroSimStat
  #
  def self.get(year, month, day)
    # Path.
    date_path = "y#{year}/m#{month}/d#{day}"
    ext = '.json'
    full_path = FIREBASE_DB_ROOT + date_path + ext

    response = Https.get(full_path)

    # JSON.
    json_hash = JSON.load(response.body)

    # Log.
    day_used = nil
    month_used_current = nil
    if !json_hash.nil?
      day_used = json_hash['day_used']
      month_used_current = json_hash['month_used_current']
    end
    log = ZeroSimStat.new(year, month, day, day_used, month_used_current)

    return log
  end

  # Store this log.
  #
  # @log ZeroSimStat
  # @return Success or not.
  #
  def store
    # Path.
    date_path = "y#{@year}/m#{@month}/d#{@day}"
    ext = '.json'
    full_path = FIREBASE_DB_ROOT + date_path + ext

    # Data.
    data = {}
    data['day_used'] = @day_used
    data['month_used_current'] = @month_used_current
    json = JSON.generate(data)

    # HTTP.
    response = Https.put(full_path, json)

    # Web API return.
    return response.code == '200'
  end

end

