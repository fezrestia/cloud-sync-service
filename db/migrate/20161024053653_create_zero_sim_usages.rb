class CreateZeroSimUsages < ActiveRecord::Migration
  def change
    create_table :zero_sim_usages do |t|
      t.integer :year
      t.integer :month
      t.integer :day
      t.integer :day_used
      t.integer :month_used_current

      t.timestamps null: false
    end
  end
end
