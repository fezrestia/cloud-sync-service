class CreateClientInfos < ActiveRecord::Migration
  def change
    create_table :client_infos do |t|
      t.string :fcm_token

      t.timestamps null: false
    end
  end
end
