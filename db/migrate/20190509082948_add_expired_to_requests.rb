class AddExpiredToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :expired, :boolean, default: false
  end
end
