module RSpecBisect
  module Ordering
    class Specified

      attr_reader :item_order

      def initialize(item_order)
        @item_order = item_order
      end

      def order(items)
        items
          .select  { |i| order_contains?(i) }
          .sort_by { |i| index_of(i)        }
      end

      private

      def order_contains?(item)
        item_order.include?(item.location)
      end

      def index_of(item)
        item_order.find_index(item.location)
      end

    end
  end
end

RSpec.configure do |config|
  order = File.open("order.log").each_line.to_a.map(&:strip)
  specified = RSpecBisect::Ordering::Specified.new(order)
  config.register_ordering(:specified) do |items|
    specified.order(items)
  end
end

module RSpec
  module Core
    class ExampleGroup
      class << self
        remove_method :ordering_strategy
        def ordering_strategy
          RSpec.configuration.ordering_registry.fetch(:specified)
        end
      end
    end

    class World
      remove_method :ordered_example_groups
      def ordered_example_groups
        ordering_strategy = @configuration.ordering_registry.fetch(:specified)
        ordering_strategy.order(@example_groups)
      end
    end
  end
end
