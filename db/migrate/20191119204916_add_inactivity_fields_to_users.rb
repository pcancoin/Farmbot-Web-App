class AddInactivityFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :inactivity_warning_sent_at, :datetime
    add_column :users, :inactivity_warning_count, :integer, default: 0
  end
end
