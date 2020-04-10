class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uuid, null: false

      t.timestamps
    end
    add_index :users, :uuid, unique: true
  end
end
