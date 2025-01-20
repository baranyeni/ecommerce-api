class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
