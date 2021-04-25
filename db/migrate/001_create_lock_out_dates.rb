class CreateLockOutDates < LOCK_OUT_PLUGIN_MIGRATION_CLASS
  def change
    unless table_exists? :lock_out_dates
      create_table :lock_out_dates do |t|
        t.integer :year
        t.integer :month
        t.boolean :locked, :default => true
      end
      add_index :lock_out_dates, [:year, :month], :unique => true
    end
  end
end
