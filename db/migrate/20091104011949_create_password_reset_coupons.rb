class CreatePasswordResetCoupons < ActiveRecord::Migration
  def self.up
    create_table :password_reset_coupons do |t|
      t.string        :code
      t.datetime      :expire_at
      t.references    :person
      t.timestamps
    end
  end

  def self.down
    drop_table :password_reset_coupons
  end
end
