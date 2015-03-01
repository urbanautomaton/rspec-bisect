module RSpec
  module Reducer
    module Ordering
      class Specified

        attr_reader :item_order

        def initialize(item_order)
          @item_order = item_order
        end

        def order(items)
          items
            .select  { |i| order_contains?(i) }
            .sort_by { |i| index_of(item)     }
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
end

RSpec.configure do |config|
  order = File.open("order.log").each_line.to_a.map(&:strip)
  defined_orderer = RSpec::Reducer::Ordering::Specified.new(order)
  config.register_ordering(:specified) do |items|
    defined_orderer.order(items)
  end
end
