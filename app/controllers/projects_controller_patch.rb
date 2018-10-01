module ProjectsControllerPatch
  def self.included(base)
    base.class_eval do
      before_filter :authorize, :except => [ :index, :list, :new, :create, :copy, :archive, :unarchive, :destroy, :timeline]
      before_filter :authorize_global, :only => [:new, :create]
      before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy]
      accept_rss_auth :index
      accept_api_auth :index, :show, :create, :update, :destroy, :timeline

      def timeline
        json = { 
          events: [
            {
              start_date: "",
              end_date: "",
              text: "",
              media: "",
              background: { color: "#17C4BB" }
            }
          ]
        }

        @timeline_events = []

        # docs.push({startDate: Date.today.strftime('%Y,%m,%d'), endDate: Date.today.strftime('%Y,%m,%d'), headline: "Aujourd'hui", text: "", tag: "", classname: ""})
        @timeline_events.push({
          start_date: {
            year: (@project.starts_date ? @project.starts_date.year : Date.today.year), 
            month: (@project.starts_date ? @project.starts_date.month : Date.today.month), 
            day: (@project.starts_date ? @project.starts_date.day : Date.today.day)
          },
          end_date: {
            year: (@project.ends_date ? @project.ends_date.year : Date.today.year),
            month: (@project.ends_date ? @project.ends_date.month : Date.today.month),
            day: (@project.ends_date ? @project.ends_date.day : Date.today.day),
          },
          text: {
            headline: @project.name,
            text: (@project.resume if @project.resume)
          },
          unique_id: "project_event"
        });


        #     , headline: p.name, text: (p.resume if p.resume), tag: "", classname: ""})


        @timeline_events.push({
          start_date: {
            year: Date.today.year,
            month: Date.today.month,
            day: Date.today.day
          },
          text: {
            text: "<div class='today'>Aujourd'hui</div>"
          }
        })

        @project.documents.visible.where(visible_in_timeline: true).each do |document|
          @timeline_events.push({
            start_date: {
              year: (document.created_date ? document.created_date.year : Date.today.year),
              month: (document.created_date ? document.created_date.month : Date.today.month),
              day: (document.created_date ? document.created_date.day : Date.today.day)
            },
            text: document.timeline_text(view_context)
          })
        end

        @project.news.visible.where(visible_in_timeline: true).each do |news|
          link = view_context.link_to(news.display_title, news, target: "_blank")
          
          @timeline_events.push({
            start_date: {
              year: news.timeline_date.year,
              month: news.timeline_date.month,
              day: news.timeline_date.day
            },
            background: { 
              color: "#17c4bb"
            },
            text: news.timeline_text(view_context)
          })
        end

        # p = @project
        # c = DocumentCategory.where(name: "Gestion de projet").first
        # docs = [{}]
        # docs.push({startDate: Date.today.strftime('%Y,%m,%d'), endDate: Date.today.strftime('%Y,%m,%d'), headline: "Aujourd'hui", text: "", tag: "", classname: ""})
        # docs.push({startDate: (p.starts_date ? p.starts_date.strftime('%Y,%m,%d') : Date.today.strftime('%Y,%m,%d')), endDate: (p.ends_date ? p.ends_date.strftime('%Y,%m,%d') : Date.today.strftime('%Y,%m,%d')), headline: p.name, text: (p.resume if p.resume), tag: "", classname: ""})
        # p.documents.visible.where(visible_in_timeline: true).each do |d|
        #   link = d.attachments.one? ? view_context.link_to(d.title,d.attachments.first, target: "_blank") : (d.url_to.nil? ? d.title : view_context.link_to(d.title, d, target: "_blank"))
        #   docs.push( {startDate: d.created_date ? d.created_date.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d') , endDate: d.created_date ? d.created_date.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d'), headline: link, text: "", tag: "", classname: ""})
        # end
        # p.news.visible.where(visible_in_timeline: true).each do |n|
        #   link = view_context.link_to(n.display_title, n, target: "_blank")
        #   docs.push( {startDate: n.timeline_display_date, endDate: n.timeline_display_date, headline: link, text: "", tag: "", classname: ""})
        # end

        respond_to do |format|
          # msg = { timeline: { headline: "", type: "default", text: "", date: docs } }
          format.json  { render :json => { events: @timeline_events }.to_json }
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

      def show
        # try to redirect to the requested menu item
        if params[:jump] && redirect_to_project_menu_item(@project, params[:jump])
          return
        end

        @users_by_role = @project.users_by_role
        @subprojects = @project.children.visible.to_a
        @news = @project.news.visible.limit(5).includes(:author, :project).order("#{News.table_name}.created_on DESC").to_a
        @trackers = @project.rolled_up_trackers.visible

        cond = @project.project_condition(Setting.display_subprojects_issues?)

        @open_issues_by_tracker = Issue.visible.open.where(cond).group(:tracker).count
        @total_issues_by_tracker = Issue.visible.where(cond).group(:tracker).count

        if User.current.allowed_to_view_all_time_entries?(@project)
          @total_hours = TimeEntry.visible.where(cond).sum(:hours).to_f
        end

        @key = User.current.rss_key

        respond_to do |format|
          format.html
          format.api
        end
      end
    end
  end
end

ProjectsController.send(:include, ProjectsControllerPatch)
