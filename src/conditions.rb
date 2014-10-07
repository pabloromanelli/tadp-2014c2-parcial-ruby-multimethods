
class Conditions

  def self.classCondition(clazz)
    proc { |value|
      value.is_a? clazz
    }
  end

  def self.valueCondition(expected_value)
    proc { |value|
      expected_value == value
    }
  end

  def self.messagesCondition(*messages)
    proc { |object|
      messages.all? { |message|
        object.respond_to? message
      }
    }
  end

end
