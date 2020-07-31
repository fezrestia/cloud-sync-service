# Base class for SIM stat.
# Sub class MUST define FIREBASE_DB_ROOT definition.
#
class SimStatBase
  include Https

  require 'net/http'
  require 'uri'

  attr_reader :year, :month, :day, :day_used, :month_used_current, :firebase_db_root
  attr_writer :day_used, :month_used_current

  INVALID_VALUE = -1

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

  # Return string for log.
  #
  # @return String Log string.
  def to_s
    return "SimStat: #{@year}/#{@month}/#{@day}, day_used=#{@day_used}, month_used_current=#{@month_used_current}"
  end

  # MUST override
  def get_firebase_db_root
    raise 'Not implemented.'
  end

  # MUST override
  def create_instance(year, month, day, day_used, month_used_current)
    raise 'Not implemented.'
  end

  # Get available all log.
  #
  # @return SimStatBase[]
  #
  def self.getAllLogArray
    # Path.
    ext = '.json'
    full_path = get_firebase_db_root + ext

    # HTTP.
    response = Https.get(full_path)

    # JSON.
    json_hash = JSON.load(response.body)

    # Parse JSON to sim stats array.
    all_logs = []
    json_hash.each { |year, month_hash|
      month_hash.each { |month, day_hash|
        day_hash.each { |day, data_hash|
          log = create_instance(
              year.delete('y').to_i,
              month.delete('m').to_i,
              day.delete('d').to_i,
              data_hash['day_used'],
              data_hash['month_used_current'])
          all_logs << log
        } # day_hash.each
      } # month_hash.each
    } # json_hash.each

    return all_logs
  end

  # Get 1 log.
  #
  # @date Date
  # @return SimStatBase
  def self.get_from_date(date)
    return get(date.year, date.month, date.day)
  end

  # Get 1 log.
  #
  # @year
  # @month
  # @day
  # @return SimStatBase
  def self.get(year, month, day)
    # Path.
    date_path = "y#{year}/m#{month}/d#{day}"
    ext = '.json'
    full_path = get_firebase_db_root + date_path + ext

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
    day_used = INVALID_VALUE if day_used.blank?
    month_used_current = INVALID_VALUE if month_used_current.blank?

    log = create_instance(year, month, day, day_used, month_used_current)

    return log
  end

end

