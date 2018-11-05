require 'active_support/concern'

module PopsProject
  extend ActiveSupport::Concern

  included do
    safe_attributes 'objectifs', 'accronym', 'resume', 'methodologies', 'results', 'perspectives', 'comments', 'url_public', 'url_project', 'starts_date', 'support_id', 'lab_name', 'sponsor', 'ends_date', 'labs_attributes'
    validates :resume, :starts_date, :ends_date, presence: true, allow_nil: false
    belongs_to :support

    delegate :name, to: :support, prefix: :support
    delegate :name, :url, to: :labs, prefix: :labs

    has_many :labs

    #before_create :generate_identifier

    accepts_nested_attributes_for :labs, reject_if: :all_blank, allow_destroy: true
  end

  module ClassMethods


    def latest(user=nil, count=5)
      # visible(user).limit(count).order("starts_date DESC").collect {|p| [p] if p.ancestors.empty? }
      visible(user).order("starts_date DESC").select {|p| [p] if p.ancestors.empty? }.first(count)
    end
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

  def css_classes
    s = 'project'
    s << ' root' if root?
    s << ' child' if child?
    s << (leaf? ? ' leaf' : ' ')
    unless active?
      if archived?
        s << ' archived'
      else
        s << ' closed'
      end
    end
  end 

  private
    def generate_identifier
      return if parent.nil? 
      self.identifier = "#{parent.identifier}-#{identifier}"
    end
end

Project.send(:include, PopsProject)

