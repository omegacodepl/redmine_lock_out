class LockOutDate < ActiveRecord::Base
  unloadable

  def <=>(other)
    if self.month == other.month &&
      self.year == other.year
      return 0
    end

    if self.year < other.year
      return -1
    end

    if self.month < other.month
      return -1
    end

    1
  end
end
