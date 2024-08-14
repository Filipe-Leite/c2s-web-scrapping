class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :brand
      t.string :model
      t.integer :price

      t.timestamps
    end
  end
end
