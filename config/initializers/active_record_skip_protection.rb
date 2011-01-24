module ActiveRecordSkipProtection
  def unprotected_update_attributes(hash)
    self.send(:attributes=, hash, false)
    self.save
  end
end

ActiveRecord::Base.send :include, ActiveRecordSkipProtection