class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :biography
      t.datetime :email_confirmed_date
      t.date :request_expiring_date
      t.date :contract_starting_date

      t.timestamps
    end
  end
end
