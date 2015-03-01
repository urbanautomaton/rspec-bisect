require 'rspec-bisect/tree/errors'

module RSpecBisect
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

      def path_to(search_name)
        return [name] if search_name == self.name
        paths = children.map { |c| c.path_to(search_name) }
        if path = paths.find { |p| !p.nil?  }
          [name] + path.flatten
        end
      end

    end
  end
end
