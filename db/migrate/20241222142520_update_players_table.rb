class UpdatePlayersTable < ActiveRecord::Migration[8.0]
  def change
    # Remove email column and its index
    remove_index :players, [ :table_id, :email ]
    remove_column :players, :email, :string

    # Add emoji column
    add_column :players, :emoji, :string

    # Remove old index and add new unique index for table_id + name
    remove_index :players, [ :table_id, :name ]
    add_index :players, [ :table_id, :name ], unique: true
  end
end
