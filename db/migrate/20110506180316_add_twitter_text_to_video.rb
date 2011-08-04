class AddTwitterTextToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :twitter_text, :string
  end

  def self.down
    remove_column :videos, :twitter_text
  end
end
