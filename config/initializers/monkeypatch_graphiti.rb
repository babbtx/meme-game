Graphiti::Adapters::ActiveRecord

# Graphiti says paginate is optional but it breaks without it
# This monkey patch removes the paging feature.
# I'm sure there's a more elegant way to do this.

module Graphiti
  module Adapters
    class ActiveRecord < ::Graphiti::Adapters::Abstract
      def paginate(scope, current_page, per_page)
        scope
      end
    end
  end
end
