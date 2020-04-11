class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :token_subject, null: false

      t.timestamps
    end
    add_index :users, :token_subject, unique: true
  end
end
