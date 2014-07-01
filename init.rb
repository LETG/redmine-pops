require File.join(File.dirname(__FILE__), 'lib/pops_project_hook_listener')
require File.join(File.dirname(__FILE__), 'app/models/project')
require File.join(File.dirname(__FILE__), 'app/models/support')
require File.join(File.dirname(__FILE__), 'app/models/news')
require File.join(File.dirname(__FILE__), 'app/models/user')
require File.join(File.dirname(__FILE__), 'app/controllers/projects_controller_patch')
require File.join(File.dirname(__FILE__), 'app/controllers/news_controller_patch')


Redmine::Plugin.register :pops_project do
  name 'Pops Project plugin'
  author 'Dotgee'
  description 'Plugin adding projects fields'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
