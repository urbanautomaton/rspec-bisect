require 'rspec-bisect/tree/node'
require 'rspec-bisect/tree/errors'

module RSpecBisect
  module Tree
    class Builder
      attr_accessor :tree

      def initialize(root_name: ".")
        @tree = @current_node = Node.new(root_name)
        @path = [@tree]
      end

      def enter(name)
        node = Node.new(name)
        current_node.children << node
        @path.push(node)
      end

      def exit
        if current_node == @tree
          raise(ExitRootError, "Attempted to exit the root node")
        end

        @path.pop
      end

      private

      def current_node
        @path.last
      end

    end
  end
end
