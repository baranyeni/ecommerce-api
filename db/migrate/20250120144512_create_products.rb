class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :unit_size, default: 1.0, precision: 10, scale: 2, null: false
      t.integer :unit_name, default: 0, null: false
      t.integer :stock_count, default: 0

      t.integer :lock_version, default: 0, null: false
      t.boolean :obsolete, default: false

      t.datetime :deleted_at
      t.timestamps
    end

    add_index :products, :obsolete
  end
end
