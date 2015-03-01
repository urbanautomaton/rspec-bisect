require 'rspec-bisect/tree/node'
require 'rspec-bisect/tree/errors'

module RSpecBisect
  module Tree
    class Builder
      attr_accessor :tree

      def initialize(root_name: ".")
        @tree = @current_node = Node.new(root_name, nil)
      end

      def enter(name)
        node = Node.new(name, @current_node)
        @current_node.children << node
        @current_node = node
      end

      def exit
        if @current_node.parent.nil?
          raise(ExitRootError, "Attempted to exit the root node")
        end

        @current_node = @current_node.parent
      end
    end
  end
end
