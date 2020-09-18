class CreateDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :discounts do |t|
      t.references :item, foreign_key: true
      t.float :discount_percent
      t.integer :minimum_quantity
      t.timestamps
    end
  end
end
