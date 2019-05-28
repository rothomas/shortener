class CreateRedirectRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :redirect_records do |t|
      t.integer :short_link_id
      t.string :referrer
      t.string :user_agent

      t.timestamps
    end
  end
end
