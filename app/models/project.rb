require 'active_support/concern'
module PopsProject
  extend ActiveSupport::Concern
  included do
    safe_attributes 'objectifs', 'accronym', 'resume', 'methodologies', 'results', 'perspectives', 'comments', 'url_public', 'url_project', 'starts_date', 'support_id', 'lab_name', 'sponsor', 'ends_date', 'labs_attributes'
    validates :accronym, :resume, :starts_date, :ends_date, presence: true, allow_nil: false
    belongs_to :support

    delegate :name, to: :support, prefix: :support
    delegate :name, :url, to: :lab, prefix: :lab

    has_many :labs

    accepts_nested_attributes_for :labs, reject_if: :all_blank, allow_destroy: true

    def self.latest(user=nil, count=5)
      # visible(user).limit(count).order("starts_date DESC").collect {|p| [p] if p.ancestors.empty? }
      visible(user).order("starts_date DESC").select {|p| [p] if p.ancestors.empty? }.first(count)
    end

    # Returns a hash of project users grouped by role
    def users_by_role
      members.includes(:user, :roles).where("name != 'Observateur'").all.inject({}) do |h, m|
        m.roles.each do |r|
          h[r] ||= []
          h[r] << m.user
        end
        h
      end
    end

  end
end
Project.send(:include, PopsProject)

