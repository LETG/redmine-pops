module ProjectsControllerPatch
  def self.included(base)
    base.class_eval do
      helper 'projects'
      helper :queries
      include QueriesHelper
      helper :projects_queries
      include ProjectsQueriesHelper

      before_action    :permit_parameters, only: [ :create, :update ]
      before_action    :authorize, :except => [ :index, :list, :new, :create, :copy, :archive, :unarchive, :destroy, :timeline ]
      before_action    :authorize_global, :only => [:new, :create ]
      before_action    :require_admin, :only => [ :copy, :archive, :unarchive, :destroy ]
      accept_atom_auth :index
      accept_api_auth  :index, :show, :create, :update, :destroy, :timeline

      self.main_menu = false

      def timeline
        @timeline_events = []

        @project.news.visible.where(visible_in_timeline: true).each do |news|
          @timeline_events.push({
            start_date: {
              year: news.timeline_date.year,
              month: news.timeline_date.month,
              day: news.timeline_date.day
            },
            text: news.timeline_text(view_context),
            group: 'Annonces'
          })
        end

        DocumentCategory.all.each do |document_category|
          @project.documents.visible.where(category_id: document_category.id, visible_in_timeline: true).each do |document|
            @timeline_events.push({
              start_date: {
                year: (document.created_date ? document.created_date.year : Date.today.year),
                month: (document.created_date ? document.created_date.month : Date.today.month),
                day: (document.created_date ? document.created_date.day : Date.today.day)
              },
              text: document.timeline_text(view_context, document_category.id),
              group: document_category.name,
            })
          end
        end

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
          unique_id: "project_event",
          group: 'Productions'
        })

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
        if params["v"]
          params["v"]  = params["v"].select { |k,v| Array.wrap(v).select(&:present?).any? } 
          params["f"]  = params["v"].keys
          params["op"] = params["op"].select { |k,v| params["f"].include?(k) }
        end

        retrieve_default_query
        retrieve_project_query
        scope = project_scope

        respond_to do |format|
          format.html {
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

      protected
        def permit_parameters
          params.permit!
        end
    end
  end
end

ProjectsController.send(:include, ProjectsControllerPatch)
