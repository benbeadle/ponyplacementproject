class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.string :pony
      t.integer :season
      t.integer :episode
      t.string :text

      t.timestamps
    end
  end
end
