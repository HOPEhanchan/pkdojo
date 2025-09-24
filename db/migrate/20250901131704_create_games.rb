class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :result
      t.string :choice
      t.string :keeper_choice

      t.timestamps
    end
  end
end
