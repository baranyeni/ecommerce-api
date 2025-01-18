class CreateCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :customers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, unique: true
      t.string :phone_number, null: false, unique: true
      t.string :password

      t.timestamps
    end
  end
end
