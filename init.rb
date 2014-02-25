require File.join(File.dirname(__FILE__), 'lib/pops_project_hook_listener')
Redmine::Plugin.register :pops_project do
  name 'Pops Project plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
