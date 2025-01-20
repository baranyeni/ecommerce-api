class CreateOrderItems < ActiveRecord::Migration[6.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity, null: false, precision: 10, scale: 2

      t.timestamps
    end

    add_index :order_items, [:order_id, :product_id], unique: true
  end
end
