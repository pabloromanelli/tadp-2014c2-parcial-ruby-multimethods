require_relative 'conditions'

class Class
  def multimethod method_name, &block
    multimethod_on(self, method_name, block)
  end

  def self_multimethod method_name, &block
    multimethod_on(self.singleton_class, method_name, block)
  end

  def multimethod_on(target_class, method_name, block)
    builder = MultimethodBuilder.new method_name
    builder.instance_eval &block
    target_class.send(:define_method, method_name, builder.build)
  end
end

class MultimethodBuilder
  def initialize method_name
    @method_name = method_name
    @conditional_methods = []
  end

  def define_for args_type, &implementation
    conditions = args_type.map { |value|
      if (value.is_a? Class)
        Conditions.classCondition value
      elsif (value.is_a? Proc)
        value
      else
        Conditions.valueCondition value
      end
    }
    @conditional_methods << ConditionalMethod.new(conditions, implementation)
  end

  def duck *messages
    Conditions.messagesCondition *messages
  end

  def build
    conditional_methods = @conditional_methods
    method_name = @method_name
    proc { |*args|
      matching_method = conditional_methods.find { |conditional_method|
        conditional_method.matches *args
      }
      if matching_method == nil
        super(*args)
      else
        self.instance_exec(*args, &matching_method.implementation)
      end
    }
  end
end

class ConditionalMethod
  attr_accessor :conditions, :implementation

  def initialize conditions, implementation
    @conditions = conditions
    @implementation = implementation
  end

  def matches *args
    matches_length(*args) && matches_every_condition(*args)
  end

  def matches_length *args
    args.length == @conditions.length
  end

  def matches_every_condition *args
    touples = @conditions.zip args
    touples.all? { |touple|
      touple[0].call touple[1]
    }
  end
end
