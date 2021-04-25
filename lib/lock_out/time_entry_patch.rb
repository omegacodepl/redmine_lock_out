module LockOut
  module TimeEntryPatch
    def self.included(base)
      base.class_eval do
        validate :check_date_for_lock_out
      end

      base.send(:include, InstanceMethods)
    end

    module InstanceMethods

      def check_date_for_lock_out
        unless self.spent_on.nil?
          unless spent_on_valid?
            errors.add :spent_on, "cannot be a previous month as that month is locked."
          end
        end
      end

      def spent_on_valid?
        self.spent_on > lock_out_date || Time.now.to_date < lock_out_date || !month_locked?
      end

      def lock_out_date
        (Time.now.beginning_of_month + ((Setting.plugin_redmine_lock_out[:lock_out_day].to_i - 1)).days).to_date
      end

      def month_locked?
        lock_out_date = LockOutDate.
          where(:month => spent_on.month, :year => spent_on.year).
          first
        return false if lock_out_date.nil?
        lock_out_date.locked
      end

    end
  end
end

TimeEntry.send(:include, LockOut::TimeEntryPatch)