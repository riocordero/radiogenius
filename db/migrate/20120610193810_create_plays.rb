class CreatePlays < ActiveRecord::Migration
  def self.up
    create_table :plays do |t|
      t.text      :search_blob
      t.string    :artist
      t.string    :song_title
      t.integer   :station_id
      t.boolean   :playing
      t.datetime  :started_at
      t.timestamps
    end

    execute 'ALTER TABLE plays ENGINE = MYISAM;'
    execute 'CREATE FULLTEXT INDEX fulltext_plays ON plays (search_blob)'
  end
  
  
  def self.down
#     execute 'DROP INDEX fulltext_plays on plays'
    drop_table :plays

  end
end
