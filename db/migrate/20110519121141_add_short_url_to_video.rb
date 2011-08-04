class AddShortUrlToVideo < ActiveRecord::Migration
  def self.up
        add_column :videos, :short_link, :string
  end

  def self.down
    remove_column :videos, :short_link
  end
end
