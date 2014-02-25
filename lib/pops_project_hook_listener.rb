class PopsProjectHookListener < Redmine::Hook::ViewListener
  render_on :view_projects_form, partial: 'projects/pops_form'
end
