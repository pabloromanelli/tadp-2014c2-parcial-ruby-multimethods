require 'rspec'
require_relative '../src/conditions'

describe 'MessagesCondition' do

  class EntiendeTodo
    attr_accessor :m1, :m2
  end

  class NoEntiendeTodo
    attr_accessor :m1
  end

  before(:each) do
    @condition = Conditions.messagesCondition(:m1, :m2)
  end

  it 'matchea si el objeto entiende todos los mensajes' do
    expect(@condition.call EntiendeTodo.new).to be true
  end

  it 'matchea si el objeto entiende todos los mensajes' do
    expect(@condition.call NoEntiendeTodo.new).to be false
  end

end
