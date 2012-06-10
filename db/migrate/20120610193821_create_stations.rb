class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :url
      t.string :name

      t.timestamps
    end
  end
end
