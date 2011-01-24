class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :logos, :kind
    add_index :logos, :person_id
    add_index :logos, :created_at
    add_index :logos, :updated_at
    add_index :logos, :delta
    
    add_index :people, :kind
    add_index :people, :email
    add_index :people, :delta
    add_index :people, :competition_winner
    add_index :people, :last_won_at


    add_index :comments, :rating
    add_index :comments, :person_id
    add_index :comments, :commentable_id
    add_index :comments, :commentable_type
    add_index :comments, :delta
    
    add_index :competitions, :approved
    add_index :competitions, :paid
    add_index :competitions, :person_id
    add_index :competitions, :delta
    
    add_index :entries, :status
    add_index :entries, :kind
    add_index :entries, :logo_id
    add_index :entries, :person_id
    add_index :entries, :enterable_id
    add_index :entries, :enterable_type
        
    add_index :page_views, :viewable_id
    add_index :page_views, :viewable_type
  end

  def self.down
    remove_index :logos, :kind
    remove_index :logos, :person_id
    remove_index :logos, :created_at
    remove_index :logos, :updated_at
    remove_index :logos, :delta
    
    remove_index :people, :kind
    remove_index :people, :email
    remove_index :people, :delta
    remove_index :people, :competition_winner
    remove_index :people, :last_won_at


    remove_index :comments, :rating
    remove_index :comments, :person_id
    remove_index :comments, :commentable_id
    remove_index :comments, :commentable_type
    remove_index :comments, :delta
    
    remove_index :competitions, :approved
    remove_index :competitions, :paid
    remove_index :competitions, :person_id
    remove_index :competitions, :delta
    
    remove_index :entries, :status
    remove_index :entries, :kind
    remove_index :entries, :logo_id
    remove_index :entries, :person_id
    remove_index :entries, :enterable_id
    remove_index :entries, :enterable_type
    
    remove_index :page_views, :viewable_id
    remove_index :page_views, :viewable_type
  end
end
