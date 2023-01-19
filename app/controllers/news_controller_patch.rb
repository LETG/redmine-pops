module NewsControllerPatch
  def self.included(base)
    base.class_eval do
      before_action :new_news

      def new_news
        @news_1 = News.new(:project => @project, :author => User.current)
        @news_1.visible_in_timeline = true
      end
    end
  end
end

NewsController.send(:include, NewsControllerPatch)