class Lab < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  belongs_to :project

  safe_attributes 'name', 'url', '_destroy'
end
