require 'yaml'
require 'open3'
require 'rspec-bisect/command'

module RSpecBisect
  class Runner

    def self.run!(args, err = $stderr, out = $stdout)
      options          = {}
      options[:bundle] = extract_bundle_option!(args)
      rspec_args       = args
      bisect_args      = filter_order_options(args)

      if rspec_args.grep(/seed|order/).empty?
        err.puts "You haven't specified an order for the spec run."
        err.puts "Without one, this tool is unable to reproduce order-dependent failures."
        exit(1)
      end

      runner = new(err, out, rspec_args, bisect_args, options)
      status = runner.run.to_i
      exit(status) if status != 0
    end

    attr_reader :err, :out, :rspec_args, :bisect_args, :options

    def initialize(err, out, rspec_args, bisect_args, options)
      @err, @out   = err, out
      @rspec_args  = rspec_args
      @bisect_args = bisect_args
      @options     = options
    end

    def run
      record_failing_run!
      identify_culprit!
    end

    private

    def self.filter_order_options(args)
      args.dup.tap do |filtered|
        if i = filtered.find_index("--order")
          # Remove the order flag and its argument
          filtered.delete_at(i)
          filtered.delete_at(i)
        end
        if i = filtered.find_index("--seed")
          # Ditto with the seed flag
          filtered.delete_at(i)
          filtered.delete_at(i)
        end
      end
    end

    def self.extract_bundle_option!(args)
      if args.delete("--no-bundle")
        false
      elsif args.delete("--bundle")
        true
      else
        true
      end
    end

    def record_failing_run!
      out.puts "Recording failing example order"
      result = run_command(recording_command)
      if result.pass?
        command_failed!("Errr... this passed:", out)
      elsif result.crashed?
        command_failed!("Recording seems to have failed:", out)
      end
    end

    def identify_culprit!
      tree     = YAML.load_file("tree.yml")
      examples = tree.leaves
      failure  = examples.pop

      out.puts "Searching within #{examples.count} candidates..."
      culprit = bisect(examples) do |candidates|
        items = candidates + [failure]
        order = order_for(tree, items)
        File.open("order.log", "w") { |f| f.puts(order) }
        result = run_command(bisect_command)

        if result.crashed?
          command_failed!("Recording seems to have failed:", out)
        end
        result.pass?
      end

      out.puts
      out.puts "The culprit appears to be at #{culprit}"
    end

    def command_failed!(message, output)
      err.puts message
      err.write output
      exit(1)
    end

    def run_command(cmd)
      RSpecBisect::Command.new(cmd)
    end

    def order_for(tree, examples)
      tree.filter(examples).to_a.flatten.drop(1)
    end

    def bundle_prefix
      "bundle exec" if options[:bundle]
    end

    def bisect(candidates)
      low  = 0
      high = candidates.length - 1
      while low < high do
        mid = (low + high) / 2
        out.write progress(candidates, low, mid)
        if yield(candidates[low..mid])
          out.puts " \u2714"
          out.write progress(candidates, mid+1, high)
          if yield(candidates[(mid+1)..high])
            out.puts " \u2714"
            puts "Uh... this bisection passed on both sides :-("
            exit(1)
          else
            out.puts " \u2718"
          end
          low = mid + 1
        else
          out.puts " \u2718"
          high = mid
        end
      end
      candidates[low]
    end

    def progress(candidates, low, high)
      prog = (0..(candidates.length - 1)).map do |i|
        (i >= low && i <= high) ? "█" : "_"
      end
      "[#{prog.join}]"
    end

    def bisect_command
      [
        bundle_prefix,
        "rspec #{bisect_args.join(" ")}",
        "--require rspec-bisect/ordering/specified"
      ].compact.join(" ")
    end

    def recording_command
      [
        bundle_prefix,
        "rspec #{rspec_args.join(" ")}",
        "--require rspec-bisect/formatters/recording",
        "--format RSpecBisect::Formatters::Recording"
      ].compact.join(" ")
    end

  end
end
