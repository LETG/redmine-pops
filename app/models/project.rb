class Project < ActiveRecord::Base
  include Redmine::SafeAttributes

  safe_attributes 'summary', 
  	'objectifs', 
	'start_date'
end

