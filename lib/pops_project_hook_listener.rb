class PopsProjectHookListener < Redmine::Hook::ViewListener
  render_on :view_projects_form, partial: 'projects/pops_form'
  render_on :view_projects_show_left, partial: 'projects/pops_show'
end
