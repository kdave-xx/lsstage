class CreateCompetitions < ActiveRecord::Migration
  def self.up
    create_table :competitions do |t|
      t.string                :name
      t.text                  :description
      
      t.integer               :organization

      t.integer               :prize_kind
      t.decimal               :prize_value
      
      t.boolean               :private
      t.decimal               :fee
      
      t.date                  :open_on
      t.date                  :close_on
      
      t.boolean               :paid
      t.datetime              :paid_at
      
      t.boolean               :approved
      t.datetime              :approved_at
      
      t.references            :person
      
      t.timestamps
    end
  end

  def self.down
    drop_table :competitions
  end
end
