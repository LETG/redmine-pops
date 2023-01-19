require 'active_support/concern'

module PopsNews
  extend ActiveSupport::Concern

  included do
    safe_attributes 'title', 'summary', 'description', 'visible_in_timeline', 'announcement_date', 'private'

    # Suppression de la validation de Redmine par défaut
    _validators[:title].reject!{ |v| v.is_a?(ActiveModel::Validations::LengthValidator) && v.options.has_key?(:maximum) }

    _validate_callbacks.each do |callback|
      callback.raw_filter.attributes.delete :title if callback.raw_filter.is_a?(ActiveModel::Validations::LengthValidator) && callback.raw_filter.options.has_key?(:maximum)
    end

    validates_length_of :title, :maximum => 150
    
    scope :visible, lambda { |*args|
      joins(:project).
      where(News.allowed_to_condition(args.shift || User.current, :view_news, *args))
    }

    def self.allowed_to_condition(user, permission, options={})
      query  = Project.allowed_to_condition(user, permission, options)
      query += " AND (news.private IS NULL OR news.private = 'f')" unless user && !user.is_a?(AnonymousUser)
      query
    end

    def timeline_date 
      announcement_date ? announcement_date :
      created_on        ? created_on : Date.today
    end

    def timeline_display_date format='%Y,%m,%d'
      announcement_date ? announcement_date.strftime(format) :
      created_on        ? created_on.strftime(format) : Date.today.strftime(format)
    end

    def display_title
      "#{title} - #{timeline_display_date('%d/%m/%Y')}"
    end

    def timeline_text(view_context)
      {
        headline: view_context.link_to("<div class='news'><div class='icon'><span class='fa fa-bullhorn'></span></div><div class='content'>#{self.display_title}</div></div>".html_safe, self, target: "_blank")
      }
    end
  end
end

News.send(:include, PopsNews)
