require 'active_support/concern'

module PopsProject
  extend ActiveSupport::Concern
  included do
    safe_attributes 'title', 'summary', 'description', 'visible_in_timeline'
  end
end
News.send(:include, PopsProject)

