require 'active_support/concern'

module PopsNews
  extend ActiveSupport::Concern

  included do
    safe_attributes 'title', 'summary', 'description', 'visible_in_timeline', 'announcement_date', 'private'
    
    scope :visible, lambda { |*args|
      joins(:project).
      where(News.allowed_to_condition(args.shift || User.current, :view_news, *args))
    }

    def self.allowed_to_condition(user, permission, options={})
      query  = Project.allowed_to_condition(user, permission, options)
      query += " AND (news.private IS NULL OR news.private = 'f')" unless user && !user.is_a?(AnonymousUser)
      query
    end

    def timeline_display_date format='%Y,%m,%d'
      announcement_date ? announcement_date.strftime(format) :
      created_on        ? created_on.strftime(format) : Date.today.strftime(format)
    end

    def display_title
      "#{title} - #{timeline_display_date('%d/%m/%Y')}"
    end
  end
end

News.send(:include, PopsNews)
