class ZeroSimUsage < ActiveRecord::Base

  # Check existence.
  validates :year, :month, :day, presence: true

  # Check numerical or not.
  validates :year, :month, :day, numericality: { only_integer: true }
  validates :day_used, :month_used_current,
      :numericality => true,
      :allow_blank => true

end

