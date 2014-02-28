require 'active_support/concern'
module PopsProject
  extend ActiveSupport::Concern
  included do
    safe_attributes 'objectifs', 'accronym', 'resume', 'methodologies', 'results', 'perspectives', 'comments', 'url_public', 'url_project', 'start_date', 'support_id'
    validates :accronym, :objectifs, presence: true, allow_nil: false
    belongs_to :support
  end
end
Project.send(:include, PopsProject)

