require 'rspec-bisect/tree/errors'

module RSpecBisect
  module Tree
    class Node
      attr_accessor :name, :children

      def self.from_a(ary)
        unless ary.is_a?(Enumerable)
          raise InvalidTreeError, "Input is not an Enumerable"
        end
        unless ary.length == 2
          raise InvalidTreeError, "Array must have exactly two elements"
        end
        unless ary.last.is_a?(Enumerable)
          raise InvalidTreeError, "Child element must be an Enumerable"
        end

        name, children_ary = ary

        new(name, children_ary.map { |c| from_a(c) })
      end

      def initialize(name, children = [])
        @name     = name
        @children = children
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

      def leaf?
        children.empty?
      end

      def leaves
        if leaf?
          [self.name]
        else
          children.flat_map(&:leaves)
        end
      end

      def filter(only_leaves)
        if leaf? && only_leaves.include?(name)
          self.class.new(name)
        else
          filtered_children = children.map { |c| c.filter(only_leaves) }.compact
          if filtered_children.length > 0
            self.class.new(name, filtered_children)
          end
        end
      end

    end
  end
end
