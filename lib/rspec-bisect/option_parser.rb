require 'optparse'

module RSpecBisect
  module OptionParser
    class << self

      def parse_with_residual!(args, options={})
        filtered_args = []
        while args.size > 0
          begin
            parse!(args, options)
          rescue ::OptionParser::InvalidOption => e
            filtered_args.push(e.to_s.sub(/invalid option:\s+/, ''))
          end
        end
        [options, filtered_args]
      end

      def parse!(args, options={})
        parser(options).parse!(args)
      end

      private

      def parser(options)
        options[:bundler] = true
        ::OptionParser.new do |opts|
          opts.on('--[no-]bundler', 'Use `bundle exec` to run commands') do |o|
            options[:bundler] = o
          end

          opts.on('--order TYPE[:SEED]', 'The order used for the failing spec run.',
                  '  [defined] examples and groups are run in the order they are defined',
                  '  [rand]    randomize the order of groups and examples',
                  '  [random]  alias for rand',
                  '  [random:SEED] e.g. --order random:123') do |o|
            options[:order] = o
          end

          opts.on('--seed SEED', Integer, 'Equivalent of --order rand:SEED.') do |seed|
            options[:order] = "rand:#{seed}"
          end
        end
      end

    end
  end
end
