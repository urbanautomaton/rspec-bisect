require 'rspec/core'
require 'rspec-bisect/tree/builder'
require 'yaml'

module RSpecBisect
  module Formatters
    class Recording < RSpec::Core::Formatters::ProgressFormatter

      def initialize(reporter)
        @builder = Tree::Builder.new
        super
      end

      RSpec::Core::Formatters.register(
        self,
        :example_group_started,
        :example_group_finished,
        :example_started,
        :example_passed,
        :example_failed,
        :example_pending,
        :stop,
      )

      def example_group_started(notification)
        @builder.enter(notification.group.location)
      end

      def example_group_finished(_)
        @builder.exit
      end

      def example_started(notification)
        @builder.enter(notification.example.location)
      end

      def example_passed(_)
        @builder.exit
      end
      alias_method :example_failed, :example_passed
      alias_method :example_pending, :example_passed

      def stop(_)
        File.open("tree.yml", "w") do |f|
          f.write(YAML.dump(@builder.tree))
        end
      end

    end
  end
end
