module NewsControllerPatch
  def self.included(base)
    base.class_eval do
      before_filter :new_news

      # def index
      #   case params[:format]
      #   when 'xml', 'json'
      #     @offset, @limit = api_offset_and_limit
      #   else
      #     @limit =  10
      #   end

      #   scope = @project ? @project.news.visible : News.visible

      #   @news_count = scope.count
      #   @news_pages = Paginator.new @news_count, @limit, params['page']
      #   @offset ||= @news_pages.offset
      #   @newss = scope.all(:include => [:author, :project],
      #                                      :order => "#{News.table_name}.created_on DESC",
      #                                      :offset => @offset,
      #                                      :limit => @limit)

      #   respond_to do |format|
      #     format.html {
      #       @news = News.new # for adding news inline
      #       @news.visible_in_timeline = true
      #       render :layout => false if request.xhr?
      #     }
      #     format.api
      #     format.atom { render_feed(@newss, :title => (@project ? @project.name : Setting.app_title) + ": #{l(:label_news_plural)}") }
      #   end
      # end

      # def new
      #   @news = News.new(:project => @project, :author => User.current)
      #   @news.visible_in_timeline = true
      # end

      def new_news
        @news_1 = News.new(:project => @project, :author => User.current)
        @news_1.visible_in_timeline = true
      end
    end
  end
end

NewsController.send(:include, NewsControllerPatch)