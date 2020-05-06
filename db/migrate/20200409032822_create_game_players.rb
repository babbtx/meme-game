class CreateGamePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :game_players do |t|
      t.references :game, null: false, foreign_key: {on_delete: :cascade}
      t.references :player, null: false, foreign_key: {to_table: :users, on_delete: :cascade}

      t.timestamps
    end
  end
end
