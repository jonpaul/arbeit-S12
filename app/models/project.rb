class Project < ActiveRecord::Base
  
  # Relationships
  has_many :tasks, :dependent => :destroy
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments
  belongs_to :domain
  belongs_to :manager, :class_name => "User", :foreign_key => "manager_id"
  
  # allow tasks to be nested within project
  accepts_nested_attributes_for :tasks, :reject_if => lambda { |task| task[:name].blank? }, :allow_destroy => true
  
  # Scopes
  scope :alphabetical,  order("name")
  scope :current,       where("start_date < ? and end_date > ?", Time.now.to_date, Time.now.to_date)
  scope :past,          where("end_date < ?", Time.now)
  scope :for_name,      lambda { |name| where("name LIKE ?", name + "%") }
  scope :for_user,      lambda { |user_id| joins(:assignments).where('user_id = ?', user_id) }
  
  # Validations
  validates_presence_of :name
  validates_date :start_date
  validates_date :end_date
  validate :domain_is_active_in_system
  
  # before_validation :convert_dates
  # 
  # def convert_dates
  #   self.start_date = Chronic.parse(self.start_date) #convert_to_date(self.start_date)
  #   self.end_date = Chronic.parse(self.end_date)
  # end
  
  # Other methods
  def is_active
    (start_date < Time.now.to_date) && (end_date > Time.now.to_date)
  end
  
  private
  def domain_is_active_in_system
    all_active_domains = Domain.active.all.map{|d| d.id}
    unless all_active_domains.include?(self.domain_id)
      errors.add(:domain_id, "is not an active domain in the system")
    end
  end
  
end
