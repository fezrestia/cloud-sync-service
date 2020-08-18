class CreateErrorLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :error_logs do |t|
      t.string :title, :null => false
      t.string :body, :null => false
      t.datetime :when, :null => false

      t.timestamps
    end
  end
end
