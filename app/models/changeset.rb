require 'active_support/concern'

module PopsChangeset
  extend ActiveSupport::Concern

  included do
    searchable_options[:columns] = [ "#{self.table_name}.comments" ]
  end
end

Changeset.send(:include, PopsChangeset)