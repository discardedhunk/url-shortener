class AddsShortened < ActiveRecord::Migration[5.1]
  def change
    add_column :urls, :shortened, :string
    add_index :urls, :shortened, unique: true
  end
end
