class AddGuestFlagsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :guest, :boolean, null: false, default: false
    add_column :users, :guest_uid, :string
    add_index  :users, :guest_uid, unique: true
  end
end
