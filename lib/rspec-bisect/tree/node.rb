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

        new(name).tap do |node|
          children = children_ary.map{|c| from_a(c)}
          node.children = children
        end
      end

      def initialize(name)
        @name = name
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

      def path_to(search_name)
        return [name] if search_name == self.name
        paths = children.map { |c| c.path_to(search_name) }
        if path = paths.find { |p| !p.nil?  }
          [name] + path.flatten
        end
      end

      def leaves
        if children.empty?
          [self.name]
        else
          children.flat_map(&:leaves)
        end
      end

      def filter(leaves)
        if children.empty? && leaves.include?(name)
          dup
        else
          filtered_children = children.map { |c| c.filter(leaves) }.compact
          if filtered_children.length > 0
            dup.tap do |copy|
              copy.children = filtered_children
            end
          end
        end
      end

    end
  end
end
