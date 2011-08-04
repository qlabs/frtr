class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :uid
      t.string :framey_name
      t.string :framey_video_url
      t.string :framey_thumbnail_url
      t.integer :views, :default => 0
      t.integer :likes, :default => 0
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
