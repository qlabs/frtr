class SetDefaultsOnVideo < ActiveRecord::Migration
  def self.up
    change_column :videos, :framey_thumbnail_url, :string, :default => "http://framey.com/images/thumb_placeholder.png"
  end

  def self.down
  end
end
