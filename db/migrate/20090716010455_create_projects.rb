class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer     :status
      t.integer     :kind
      t.integer     :permission
      t.decimal     :prize_value, :precision => 9, :scale => 2
      
      
      t.string      :name
      t.text        :brief
      t.date        :deadline
      
      t.string      :url
      t.string      :location
      t.string      :company_size
      t.string      :payment_term
      t.string      :payment_currency
      t.text        :other_requirement

      t.references  :person
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
