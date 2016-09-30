class Fixnum
  def seconds_ago
    Time.now - self
  end
  alias_method :second_ago, :seconds_ago

  def minutes_ago
    Time.now - (self * 60)
  end
  alias_method :minute_ago, :minutes_ago

  def hours_ago
    Time.now - (self * 60 * 60)
  end
  alias_method :hour_ago, :hours_ago

  def days_ago
    Time.now - (self * 60 * 60 * 24)
  end
  alias_method :day_ago, :days_ago
end
