# ApplicationResource is similar to ApplicationRecord - a base class that
# holds configuration/methods for subclasses.
# All Resources should inherit from ApplicationResource.
class ApplicationResource < Graphiti::Resource
  # Use the ActiveRecord Adapter for all subclasses.
  # Subclasses can still override this default.
  self.abstract_class = true
  self.adapter = Graphiti::Adapters::ActiveRecord
  self.base_url = Rails.application.routes.default_url_options[:host]
  self.endpoint_namespace = '/api/v1'

  self.attributes_writable_by_default = false # default true
  self.attributes_filterable_by_default = false # default true
  self.attributes_sortable_by_default = false # default true

  # In order to have mutability of create-only,
  # I need to add attribute conditions like "writable: :creating?".
  #
  # Not sure the best path ...
  # Using the [controller] context.action_name seems to plug only one path to update.
  # I see this being set by the Resource during update, so I'll go with that.
  def creating?
    Graphiti.context[:namespace] != :update
  end
end
