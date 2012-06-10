class CreatePlays < ActiveRecord::Migration
  def change
    create_table :plays do |t|
      t.datetime :start_time
      t.text :search_blob
      t.string :artist
      t.string :song_title
      t.integer :station_id

      t.timestamps
    end

    execute 'ALTER TABLE plays ENGINE = MYISAM;'
    execute 'CREATE FULLTEXT INDEX fulltext_plays ON plays (search_blob)'
  end
end
