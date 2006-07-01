module Spec
  module Runner
    class Reporter
      
      def initialize(formatter, backtrace_tweaker)
        @formatter = formatter
        @context_names = []
        @failures = []
        @spec_names = []
        @backtrace_tweaker = backtrace_tweaker
      end
  
      def add_context(name)
        #TODO - @context_names.empty? tells the formatter whether this is the first context or not - that's a little slippery
        @formatter.add_context(name, @context_names.empty?)
        @context_names << name
      end
      
      def spec_started(name)
        @spec_names << name
        @formatter.spec_started(name)
      end
      
      def spec_finished(name, error=nil, failure_location=nil)
        if error.nil?
          spec_passed(name)
        else
          @backtrace_tweaker.tweak_backtrace(error, failure_location)
          spec_failed(name, Failure.new(@context_names.last, name, error))
        end
      end
      
      def start(number_of_specs)
        @start_time = Time.new
        @formatter.start(number_of_specs)
      end
  
      def end
        @end_time = Time.new
      end
  
      # Dumps the summary and returns the total number of failures
      def dump
        @formatter.start_dump
        dump_failures
        @formatter.dump_summary(duration, @spec_names.length, @failures.length)
        @failures.length
      end

      private
  
      def dump_failures
        return if @failures.empty?
        @failures.inject(1) do |index, failure|
          @formatter.dump_failure(index, failure)
          index + 1
        end
      end

      def duration
        return @end_time - @start_time unless (@end_time.nil? or @start_time.nil?)
        return "0.0"
      end

      def spec_passed(name)
        @formatter.spec_passed(name)
      end

      def spec_failed(name, failure)
        @failures << failure
        @formatter.spec_failed(name, @failures.length, failure)
      end

      class Failure
        def initialize(context_name, spec_name, exception)
          @context_name = context_name
          @spec_name = spec_name
          @exception = exception
        end

        def header
          "#{class_name} in '#{@context_name} #{@spec_name}'"
        end

        def message
          @exception.message
        end

        def backtrace
          @exception.backtrace.nil? ? "" : @exception.backtrace.join("\n")
        end

        private

        def class_name
          @exception.class.name #.split('::').last
        end

      end
    end
  end
end