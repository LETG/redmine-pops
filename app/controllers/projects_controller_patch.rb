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
        docs.push({startDate: (p.starts_date ? p.starts_date.strftime('%Y,%m,%d') : Date.today.strftime('%Y,%m,%d')), endDate: (p.ends_date ? p.ends_date.strftime('%Y,%m,%d') : Date.today.strftime('%Y,%m,%d')), headline: p.accronym, text: (p.resume if p.resume), tag: "", classname: ""})
        p.documents.visible.where(visible_in_timeline: true).each do |d|
          link = d.attachments.any? ? view_context.link_to(d.title,d.attachments.first, target: "_blank") : (d.url_to.nil? ? d.title : view_context.link_to(d.title, d.url_to, target: "_blank"))
          docs.push( {startDate: d.created_date ? d.created_date.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d') , endDate: d.created_date ? d.created_date.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d'), headline: link, text: "", tag: "", classname: ""})
        end
        p.news.where(visible_in_timeline: true).each do |n|
          link = view_context.link_to(n.title, n, target: "_blank")
          docs.push( {startDate: n.created_on ? n.created_on.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d') , endDate: n.created_on ? n.created_on.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d'), headline: link, text: "", tag: "", classname: ""})
        end

        respond_to do |format|
          msg = { timeline: { headline: "", type: "default", text: "", date: docs } }
          format.json  { render :json => msg }
        end
      end
    end

  end
end

ProjectsController.send(:include, ProjectsControllerPatch)