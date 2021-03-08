require File.dirname(File.expand_path(__FILE__)) + '/./test_helper'

# reopen time class to stub out what I need for testing, as the code
# is based on the current time - so I can now set the 'current time'
# as the code sees it.
class Time
  def self.current=(value)
    @current = value
  end

  class << self
    alias :old_now :now
  end

  def self.now
    @current || Time.old_now
  end
end

class TimeEntryPatchTest < ActionController::TestCase
  fixtures :users, :projects, :issues, :enumerations

  def setup
    @user = User.first
    @issue = Issue.first
    @activity = TimeEntryActivity.first
    @time_entry = TimeEntry.new(
      :issue => @issue,
      :hours => 1,
      :user => @user,
      :project => @issue.project,
      :activity => @activity
    )
    Time.current = nil
    Setting['plugin_lock_out']['lock_out_day'] = 1
  end

  def teardown
    Time.current = nil
    Setting['plugin_lock_out']['lock_out_day'] = 1
  end

  def test_entered_first_day_of_month_for_last_month
    Time.current = Time.now.beginning_of_month
    @time_entry.spent_on = Time.now - 5.days
    assert_equal true, @time_entry.save
  end

  def test_entered_first_day_of_month_when_disallowed
    Setting['plugin_lock_out']['lock_out_day'] = 0
    Time.current = Time.now.beginning_of_month
    @time_entry.spent_on = Time.now - 5.days
    assert_equal false, @time_entry.save
    assert_equal 1, @time_entry.errors[:spent_on].count
    assert_equal "cannot be a previous month as that month is locked.", @time_entry.errors[:spent_on].first
  end

  def test_entered_on_last_day_of_month_as_last_allowed
    Setting['plugin_lock_out']['lock_out_day'] = 0
    Time.current = Time.now.end_of_month
    @time_entry.spent_on = Time.now - 5.days
    assert_equal true, @time_entry.save
  end

  def test_entered_on_last_day_of_month_for_last_day_of_month
    Setting['plugin_lock_out']['lock_out_day'] = 0
    Time.current = Time.now.end_of_month
    @time_entry.spent_on = Time.now
    assert_equal true, @time_entry.save
  end

  def test_entered_second_day_of_month_for_last_month
    Time.current = Time.now.beginning_of_month + 1.day
    @time_entry.spent_on = Time.now - 6.days
    assert_equal false, @time_entry.save
    assert_equal 1, @time_entry.errors[:spent_on].count
    assert_equal "cannot be a previous month as that month is locked.", @time_entry.errors[:spent_on].first
  end

  def test_entered_third_day_of_month_with_setting_allowing_it
    Setting['plugin_lock_out']['lock_out_day'] = 3
    Time.current = Time.now.beginning_of_month + 2.days
    @time_entry.spent_on = Time.now - 8.days
    assert_equal true, @time_entry.save
  end

  def test_spent_on_is_last_month
    @time_entry.spent_on = Time.now - 1.month
    assert_equal false, @time_entry.save
    assert_equal 1, @time_entry.errors[:spent_on].count
    assert_equal "cannot be a previous month as that month is locked.", @time_entry.errors[:spent_on].first
  end

  def test_spent_on_is_past_month_is_unlocked
    lock_out_date = LockOutDate.create(
      :month => (Time.now - 1.month).month,
      :year => (Time.now - 1.month).year,
      :locked => false
    )
    @time_entry.spent_on = Time.now - 1.month
    assert_equal true, @time_entry.save
  end

  def test_spent_on_is_last_day_of_month
    @time_entry.spent_on = (Time.now - 1.month).end_of_month
    assert_equal false, @time_entry.save
    assert_equal 1, @time_entry.errors[:spent_on].count
    assert_equal "cannot be a previous month as that month is locked.", @time_entry.errors[:spent_on].first
  end

  def test_spent_on_is_nil
    assert_equal false, @time_entry.save
    assert_equal 1, @time_entry.errors[:spent_on].count
    assert_equal "can't be blank", @time_entry.errors[:spent_on].first
  end

  def test_spent_on_is_this_month
    @time_entry.spent_on = Time.now
    assert_equal true, @time_entry.save
  end

  def test_spent_on_is_next_month
    @time_entry.spent_on = Time.now + 1.month
    assert_equal true, @time_entry.save
  end

  def test_spent_on_is_next_month_next_year
    @time_entry.spent_on = (Time.now + 1.month) + 1.year
    assert_equal true, @time_entry.save
  end

  def test_spent_on_is_last_month_next_year
    @time_entry.spent_on = (Time.now - 1.month) + 1.year
    assert_equal true, @time_entry.save
  end

  def test_spent_on_is_next_month_last_year
    @time_entry.spent_on = (Time.now + 1.month) - 1.year
    assert_equal false, @time_entry.save
    assert_equal 1, @time_entry.errors[:spent_on].count
    assert_equal "cannot be a previous month as that month is locked.", @time_entry.errors[:spent_on].first
  end

end
