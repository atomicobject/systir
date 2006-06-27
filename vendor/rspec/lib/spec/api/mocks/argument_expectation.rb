module Spec
  module Api
  
    class LiteralArgConstraint
      def initialize(literal)
        @literal_value = literal
      end
      
      def matches?(value)
        @literal_value == value
      end
    end
    
    class AnyArgConstraint
      def initialize(ignore)
      end
      
      def matches?(value)
        true
      end
    end
    
    class NumericArgConstraint
      def initialize(ignore)
      end
      
      def matches?(value)
        value.is_a?(Numeric)
      end
    end
    
    class BooleanArgConstraint
      def initialize(ignore)
      end
      
      def matches?(value)
        return true if value.is_a?(TrueClass)
        return true if value.is_a?(FalseClass)
        false
      end
    end
    
    class StringArgConstraint
      def initialize(ignore)
      end
      
      def matches?(value)
        value.is_a?(String)
      end
    end
    
    class DuckTypeArgConstraint
      def initialize(*methods_to_respond_do)
        @methods_to_respond_do = methods_to_respond_do
      end
  
      def matches?(value)
        @methods_to_respond_do.all? { |sym| value.respond_to?(sym) }
      end
    end

    class ArgumentExpectation
    
      @@constraint_classes = Hash.new { |hash, key| LiteralArgConstraint}
      @@constraint_classes[:anything] = AnyArgConstraint
      @@constraint_classes[:numeric] = NumericArgConstraint
      @@constraint_classes[:boolean] = BooleanArgConstraint
      @@constraint_classes[:string] = StringArgConstraint
      
      def initialize(args)
        if args == [:any_args] then @expected_params = nil
        elsif args == [:no_args] then @expected_params = []
        else @expected_params = process_arg_constraints(args)
        end
      end
      
      def process_arg_constraints(constraints)
        constraints.collect do |constraint| 
          convert_constraint(constraint)
        end
      end
      
      def convert_constraint(constraint)
        return @@constraint_classes[constraint].new(constraint) if constraint.is_a?(Symbol)
        return constraint if constraint.is_a?(DuckTypeArgConstraint)
        return LiteralArgConstraint.new(constraint)
      end
      
      def check_args(args)
        return true if @expected_params.nil?
        return true if @expected_params == args
        return constraints_match?(args)
      end
      
      def constraints_match?(args)
        return false if args.length != @expected_params.length
        @expected_params.each_index { |i| return false unless @expected_params[i].matches?(args[i]) }
        return true
      end
  
    end
    
  end
end
