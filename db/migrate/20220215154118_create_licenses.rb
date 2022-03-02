class CreateLicenses < ActiveRecord::Migration[6.1]
  def change
    create_table :licenses do |t|
      t.string :key
      t.references :game, foreign_key: {to_table: :games}
      t.references :user, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
