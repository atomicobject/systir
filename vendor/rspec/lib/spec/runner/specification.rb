module Spec
  module Runner
    class Specification
    
      def initialize(name, &block)
        @name = name
        @block = block
        @mocks = []
      end
    
      def run(reporter=nil, setup_block=nil, teardown_block=nil, dry_run=false)
        reporter.spec_started(@name)
        if dry_run
          reporter.spec_finished(@name)
        else
          execution_context = ::Spec::Runner::ExecutionContext.new(self)
          errors = []
          begin
            execution_context.instance_exec(&setup_block) unless setup_block.nil?
            setup_ok = true
            execution_context.instance_exec(&@block)
            spec_ok = true
          rescue => e
            errors << e
          end

          begin
            execution_context.instance_exec(&teardown_block) unless teardown_block.nil?
            teardown_ok = true
            @mocks.each do |mock|
              mock.__verify
            end
          rescue => e
            errors << e
          end

          reporter.spec_finished(@name, errors.first, failure_location(setup_ok, spec_ok, teardown_ok)) unless reporter.nil?
        end
      end
      
      def add_mock(mock)
        @mocks << mock
      end
      
      def matches_matcher?(matcher)
        matcher.matches? @name 
      end
            
      private
      
      def failure_location(setup_ok, spec_ok, teardown_ok)
        return 'setup' unless setup_ok
        return @name unless spec_ok
        return 'teardown' unless teardown_ok
      end
    
    end
  end
end