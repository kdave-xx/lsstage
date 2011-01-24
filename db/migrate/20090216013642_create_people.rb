class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.integer       :kind
      
      t.string        :nick_name
      t.string        :first_name
      t.string        :last_name
      t.string        :email
      t.string        :paypal_account
      t.string        :password_hash
      t.string        :password_salt
      
      t.string        :last_login_at
      t.string        :last_login_ip_address

      
      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
