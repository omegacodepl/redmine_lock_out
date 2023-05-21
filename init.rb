require 'redmine'

require_relative './lib/lock_out/time_entry_patch.rb'

if Rails::VERSION::MAJOR >= 5
  version = "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}".to_f
  LOCK_OUT_PLUGIN_MIGRATION_CLASS = ActiveRecord::Migration[version]
else
  LOCK_OUT_PLUGIN_MIGRATION_CLASS = ActiveRecord::Migration
end

Redmine::Plugin.register :redmine_lock_out do
  name 'Redmine Lock Out'
  author 'Tomasz Gietek for Omega Code Sp. z o.o.'
  description 'Redmine Plugin that locks timesheet entries for the previous month unless allowed by admin.'
  version '2.0.4'

  permission :view_lock_dates, { :redmine_lock_out => :index }
  permission :alter_lock_dates, { :redmine_lock_out => [:lock, :unlock] }

  # settings for what day of the month the lockout occurs
  settings :partial => 'lock_out_settings',
           :default => { :lock_out_day => 1 }

  menu :top_menu, :redmine_lock_out, { :controller => 'lock_out', :action => 'index' }, :caption => "Lock out dates", :if => Proc.new { User.current.allowed_to?({ :controller => 'lock_out', :action => 'index' }, nil, :global => true) }
end
