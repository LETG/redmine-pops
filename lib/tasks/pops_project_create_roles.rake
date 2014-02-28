require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')

class PopsProjectCreateRoles
  include Redmine::I18n

  def self.create
    Role.create!(name: "Administrateur", position: 1, assignable: true, builtin: 0, permissions: [:add_project, :edit_project, :close_project, :select_project_modules, :manage_members, :manage_versions, :add_subprojects, :manage_boards, :add_messages, :edit_messages, :edit_own_messages, :delete_messages, :delete_own_messages, :view_calendar, :add_documents, :edit_documents, :delete_documents, :view_documents, :manage_files, :view_files, :view_gantt, :manage_categories, :view_issues, :add_issues, :edit_issues, :manage_issue_relations, :manage_subtasks, :set_issues_private, :set_own_issues_private, :add_issue_notes, :edit_issue_notes, :edit_own_issue_notes, :view_private_notes, :set_notes_private, :move_issues, :delete_issues, :manage_public_queries, :save_queries, :view_issue_watchers, :add_issue_watchers, :delete_issue_watchers, :manage_news, :comment_news, :manage_repository, :browse_repository, :view_changesets, :commit_access, :manage_related_issues, :log_time, :view_time_entries, :edit_time_entries, :edit_own_time_entries, :manage_project_activities, :manage_wiki, :rename_wiki_pages, :delete_wiki_pages, :view_wiki_pages, :export_wiki_pages, :view_wiki_edits, :edit_wiki_pages, :delete_wiki_pages_attachments, :protect_wiki_pages], issues_visibility: "all")


    Role.create!(name: "Contributeur", position: 2, assignable: true, builtin: 0, permissions: [:manage_versions, :manage_categories, :view_issues, :add_issues, :edit_issues, :view_private_notes, :set_notes_private, :manage_issue_relations, :manage_subtasks, :add_issue_notes, :save_queries, :view_gantt, :view_calendar, :log_time, :view_time_entries, :comment_news, :view_documents, :view_wiki_pages, :view_wiki_edits, :edit_wiki_pages, :delete_wiki_pages, :add_messages, :edit_own_messages, :view_files, :manage_files, :browse_repository, :view_changesets, :commit_access, :manage_related_issues], issues_visibility: "default")


    Role.create!(name: "Observateur", position: 3, assignable: true, builtin: 0, permissions: [:view_issues, :add_issues, :add_issue_notes, :save_queries, :view_gantt, :view_calendar, :log_time, :view_time_entries, :comment_news, :view_documents, :view_wiki_pages, :view_wiki_edits, :add_messages, :edit_own_messages, :view_files, :browse_repository, :view_changesets], issues_visibility: "default")
  end

end

namespace :redmine do
  task :pops_project_create_roles => :environment do
    PopsProjectCreateRoles.create
  end
end
