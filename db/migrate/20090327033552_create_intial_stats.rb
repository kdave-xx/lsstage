class CreateIntialStats < ActiveRecord::Migration
  def self.up
    Person.all.each(&:create_statistic)
    Logo.all.each(&:create_statistic)
  end

  def self.down
  end
end
