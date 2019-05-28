class CreateShortLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :short_links do |t|
      t.string :long_url, nullable: false
      t.string :short_code, unique: true, nullable: false

      t.timestamps
    end
  end
end
