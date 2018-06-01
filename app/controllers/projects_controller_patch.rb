module ProjectsControllerPatch
  def self.included(base)
    base.class_eval do
      before_filter :authorize, :except => [ :index, :list, :new, :create, :copy, :archive, :unarchive, :destroy, :timeline]
      before_filter :authorize_global, :only => [:new, :create]
      before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy]
      accept_rss_auth :index
      accept_api_auth :index, :show, :create, :update, :destroy, :timeline

      def timeline
        p = @project
        c = DocumentCategory.where(name: "Gestion de projet").first
        docs = [{}]
        docs.push({startDate: Date.today.strftime('%Y,%m,%d'), endDate: Date.today.strftime('%Y,%m,%d'), headline: "Aujourd'hui", text: "", tag: "", classname: ""})
        docs.push({startDate: (p.starts_date ? p.starts_date.strftime('%Y,%m,%d') : Date.today.strftime('%Y,%m,%d')), endDate: (p.ends_date ? p.ends_date.strftime('%Y,%m,%d') : Date.today.strftime('%Y,%m,%d')), headline: p.name, text: (p.resume if p.resume), tag: "", classname: ""})
        p.documents.visible.where(visible_in_timeline: true).each do |d|
          link = d.attachments.one? ? view_context.link_to(d.title,d.attachments.first, target: "_blank") : (d.url_to.nil? ? d.title : view_context.link_to(d.title, d, target: "_blank"))
          docs.push( {startDate: d.created_date ? d.created_date.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d') , endDate: d.created_date ? d.created_date.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d'), headline: link, text: "", tag: "", classname: ""})
        end
        p.news.where(visible_in_timeline: true).each do |n|
          link = view_context.link_to(n.display_title, n, target: "_blank")
          docs.push( {startDate: n.timeline_display_date, endDate: n.timeline_display_date, headline: link, text: "", tag: "", classname: ""})
        end

        respond_to do |format|
          msg = { timeline: { headline: "", type: "default", text: "", date: docs } }
          format.json  { render :json => msg }
        end
      end

      def new
        @issue_custom_fields = IssueCustomField.sorted.all
        @trackers = Tracker.sorted.all
        @project = Project.new
        @project.safe_attributes = params[:project]
        @project.labs.build
      end

      def edit
        @project.labs.build
      end
      # Lists visible projects
      def index
        respond_to do |format|
          format.html {
            scope = Project
            @projects = scope.active.visible.order('lft').all
            @archived = scope.where(status: [Project::STATUS_CLOSED, Project::STATUS_ARCHIVED]).visible.order('lft').all
          }
          format.api  {
            @offset, @limit = api_offset_and_limit
            @project_count = Project.visible.count
            @projects = Project.visible.offset(@offset).limit(@limit).order('lft').all
          }
          format.atom {
            projects = Project.visible.order('created_on DESC').limit(Setting.feeds_limit.to_i).all
            render_feed(projects, :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
          }
        end
      end
    end
  end
end

ProjectsController.send(:include, ProjectsControllerPatch)
