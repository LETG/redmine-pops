require 'active_support/concern'
module PopsProject
  extend ActiveSupport::Concern
  included do
    safe_attributes 'objectifs', 'accronym', 'resume', 'methodologies', 'results', 'perspectives', 'comments', 'url_public', 'url_project', 'starts_date', 'support_id', 'lab_name', 'sponsor', 'ends_date'
    validates :accronym, :resume, :starts_date, :ends_date, presence: true, allow_nil: false
    belongs_to :support

    delegate :name, to: :support, prefix: :support

    def self.latest(user=nil, count=5)
      visible(user).limit(count).order("starts_date DESC").all
    end

  end
end
Project.send(:include, PopsProject)

