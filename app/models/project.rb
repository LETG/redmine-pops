require 'active_support/concern'
module PopsProject
  extend ActiveSupport::Concern
  included do
    safe_attributes 'objectifs', 'accronym', 'resume', 'methodologies', 'results', 'perspectives', 'comments', 'url_public', 'url_project', 'start_date'
    validates :accronym, :objectifs, presence: true, allow_nil: false
  end
end
Project.include(PopsProject)

