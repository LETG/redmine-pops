module ProjectsControllerPatch
  def self.included(base)
    base.class_eval do
      before_filter :authorize, :except => [ :index, :list, :new, :create, :copy, :archive, :unarchive, :destroy, :timeline]
      before_filter :authorize_global, :only => [:new, :create]
      before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy, :timeline]
      accept_rss_auth :index
      accept_api_auth :index, :show, :create, :update, :destroy, :timeline

      def timeline
        p = @project
        c = DocumentCategory.find_by_name('Productions')
        docs = [{}]
        docs.push({startDate: Date.today.strftime('%Y,%m,%d'), endDate: Date.today.strftime('%Y,%m,%d'), headline: "Aujourd'hui", text: "", tag: "", classname: ""})
        docs.push({startDate: (p.starts_date ? p.starts_date.strftime('%Y,%m,%d') : Date.today.strftime('%Y,%m,%d')), endDate: (p.ends_date ? p.ends_date.strftime('%Y,%m,%d') : Date.today.strftime('%Y,%m,%d')), headline: p.accronym, text: (p.resume if p.resume), tag: "", classname: ""})
        p.documents.where(category_id: c.id).each do |d|
          docs.push( {startDate: d.created_date ? d.created_date.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d') , endDate: d.created_date ? d.created_date.strftime("%Y,%m,%d") : Date.today.strftime('%Y,%m,%d'), headline: d.title, text: "", tag: "", classname: ""})
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