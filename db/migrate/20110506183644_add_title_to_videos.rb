class AddTitleToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :title, :string
  end

  def self.down
    remove_column :videos, :title
  end
end
