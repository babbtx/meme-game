class CreateAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :answers do |t|
      t.string :url, null: false
      t.json :captions
      t.integer :rating
      t.references :user, null: false, foreign_key: {on_delete: :cascade}
      t.references :game, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
