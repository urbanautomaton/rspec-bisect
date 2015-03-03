require 'open3'

module RSpecBisect
  class Command
    attr_reader :command

    attr_reader :result, :output

    def initialize(command)
      @command = command
      run!
    end

    def run!
      Open3.popen2e(command) do |_, out_and_err, wait_thr|
        @result = wait_thr.value
        @output = out_and_err.read
      end
    end

    def crashed?
      !suite_finished?
    end

    def pass?
      suite_finished? && result.success?
    end

    def fail?
      suite_finished? && !result.success?
    end

    private

    def suite_finished?
      output =~ /Finished.*seconds/
    end
  end
end
