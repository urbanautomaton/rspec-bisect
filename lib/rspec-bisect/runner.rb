require 'yaml'
require 'open3'
require 'rspec-bisect/option_parser'

module RSpecBisect
  class Runner

    def self.run!(args, err=$stderr, out=$stdout)
      original_args          = args.dup
      options, bisect_args = OptionParser.parse_with_residual!(args)

      unless options.has_key?(:order)
        err.puts "You haven't specified an order for the spec run."
        err.puts "Without one, this tool is unable to reproduce order-dependent failures."
        exit(1)
      end

      runner = new(err, out, original_args, bisect_args, options)
      status = runner.run.to_i
      exit(status) if status != 0
    end

    attr_reader :err, :out, :original_args, :bisect_args, :options

    def initialize(err, out, original_args, bisect_args, options)
      @err, @out     = err, out
      @original_args = original_args
      @bisect_args   = bisect_args
      @options       = options
    end

    def run
      record_failing_run!
      identify_culprit!
    end

    private

    def record_failing_run!
      out.puts "Recording failing example order"
      out.puts recording_command
      Open3.popen2e(recording_command) do |stdin, stdout_and_stderr, wait_thr|
        out = stdout_and_stderr.read
        if wait_thr.value.success?
          err.puts "Errr... this passed:"
          err.write out
          exit(1)
        elsif !(out =~ /Finished.*seconds/)
          err.puts "Recording seems to have failed:"
          err.write out
          exit(1)
        end
      end
    end

    def identify_culprit!
      tree     = YAML.load_file("tree.yml")
      examples = tree.leaves
      failure  = examples.pop

      culprit = bisect(examples) do |candidates|
        items = candidates + [failure]
        order = order_for(tree, items)
        File.open("order.log", "w") { |f| f.puts(order) }
        result = false
        Open3.popen3(bisect_command) do |_i, _o, _e, wait_thr|
          result = wait_thr.value.success?
        end
        result
      end

      out.puts
      out.puts "The culprit appears to be at #{culprit}"
    end

    def order_for(tree, examples)
      tree.filter(examples).to_a.flatten.drop(1)
    end

    def bundle_prefix
      "bundle exec" if options[:bundler]
    end

    def bisect(candidates)
      low  = 0
      high = candidates.length - 1
      while low < high do
        out.puts "Searching #{candidates[low..high].count} examples"
        mid = (low + high) / 2
        if yield(candidates[low..mid])
          low = mid + 1
        else
          high = mid
        end
      end
      candidates[low]
    end

    def command(parts)
      parts.compact.join(" ")
    end

    def bisect_command
      command([
        bundle_prefix,
        "rspec #{bisect_args.join(" ")}",
        "--require rspec-bisect/ordering/specified"
      ])
    end

    def recording_command
      command([
        bundle_prefix,
        "rspec #{original_args.join(" ")}",
        "--require rspec-bisect/formatters/recording",
        "--format RSpecBisect::Formatters::Recording"
      ])
    end

  end
end
