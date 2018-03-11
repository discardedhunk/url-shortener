class AddsIndexUniquToUrls < ActiveRecord::Migration[5.1]
  def change
    add_index :urls, :original, unique: true
  end
end
