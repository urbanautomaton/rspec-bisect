require 'rspec/reducer/tree/errors'

module RSpec
  module Reducer
    module Tree
      class Node
        attr_accessor :name, :parent, :children

        def initialize(name, parent)
          @name, @parent = name, parent
          @children = []
        end

        def to_a
          [name, children.map(&:to_a)]
        end

        def ==(other)
          name == other.name && children == other.children
        end

        def eql?(other)
          self == other
        end

      end
    end
  end
end
