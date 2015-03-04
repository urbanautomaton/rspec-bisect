module RSpecBisect
  module Ordering
    class Specified

      attr_reader :item_order

      def self.default
        new(File.readlines("order.log").map(&:chomp))
      end

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

module RSpec
  module Core
    class ExampleGroup
      class << self
        remove_method :ordering_strategy
        def ordering_strategy
          RSpecBisect::Ordering::Specified.default
        end
      end
    end

    class World
      remove_method :ordered_example_groups
      def ordered_example_groups
        ordering_strategy = RSpecBisect::Ordering::Specified.default
        ordering_strategy.order(@example_groups)
      end
    end
  end
end
