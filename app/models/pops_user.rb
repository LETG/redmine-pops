require 'active_support/concern'

module PopsUser
  extend ActiveSupport::Concern
  included do
    safe_attributes 'login',
    'firstname',
    'lastname',
    'mail',
    'mail_notification',
    'notified_project_ids',
    'language',
    'custom_field_values',
    'custom_fields',
    'identity_url',
    'url'
  end
end

User.send(:include, PopsUser)
