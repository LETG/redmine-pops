require 'active_support/concern'

module PopsNews
  extend ActiveSupport::Concern

  included do
    safe_attributes 'title', 'summary', 'description', 'visible_in_timeline', 'announcement_date'

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
