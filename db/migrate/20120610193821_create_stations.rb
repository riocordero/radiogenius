class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string    :url
      t.string    :name
      t.string    :stream_type
      t.timestamps
    end
  end
end
