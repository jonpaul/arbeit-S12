class Domain < ActiveRecord::Base
  # Relationships
  has_many :projects
      
  # Validations
  validates_presence_of :name
  
  # Scopes
  scope :alphabetical, order('name')
  scope :active, where('active = ?', true)
  
end
