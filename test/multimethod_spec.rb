require 'rspec'
require_relative '../src/multimethod'

class StringUtils1
  multimethod :concat do
    define_for [String, String] do |s1, s2|
      s1 + s2
    end
    define_for [String, Integer] do |s, n|
      s * n
    end
    define_for [Array] do |a|
      a.join
    end
  end
end

class StringUtils2
  multimethod :concat do
    define_for [nil] do |o|
      nil
    end
    define_for [String, -1] do |s, n|
      s.reverse
    end
    define_for [String, proc {|o| o.odd? or o > 42}] do |s, n|
      true
    end
    define_for [String, Integer] do |s, n|
      s * n
    end
  end
end

class Persona
  attr_accessor :nombre, :apellido

  def initialize
    @nombre = 'Johann Sebastian'
    @apellido = 'Mastropiero'
  end
end

class StringUtils3
  multimethod :concat do
    define_for [String, duck(:nombre, :apellido)] do |s, p|
      "#{s} #{p.nombre} #{p.apellido}"
    end
    define_for [String, String] do |s1, s2|
      s1 + s2
    end
    define_for [String, Integer] do |s, n|
      s * n
    end
  end
end

class StringUtils4
  self_multimethod :concat do
    define_for [String, String] do |s1, s2|
      s1 + s2
    end
    define_for [String, Integer] do |s, n|
      s * n
    end
  end
end

class StringUtils5
  multimethod :concat do
    define_for [String, String] do |s1, s2|
      s1 + s2
    end

    define_for [String, Integer] do |s, n|
      s * n
    end
  end
end

class ChildStringUtils5 < StringUtils5
  multimethod :concat do
    define_for [String, String] do |s1, s2|
      s2 + s1
    end

    define_for [String, Array] do |s, a|
      a.join s
    end
  end
end

describe 'Multimethod' do

  before(:each) do
    @utils1 = StringUtils1.new
    @utils2 = StringUtils2.new
    @utils3 = StringUtils3.new
    @utils5 = ChildStringUtils5.new
  end

  it 'puede definir multimethod' do
    expect(@utils1.concat('hola', 'mundo')).to eq('holamundo')
    expect(@utils1.concat('hola', 3)).to eq('holaholahola')
    expect(@utils1.concat(['hola', ' ', 'mundo'])).to eq('hola mundo')
  end

  it 'lanza NoMethodError si no matchea ninguno' do
    expect {
      @utils1.concat(4, 4)
    }.to raise_error NoMethodError
  end

  it 'puede matchear por valor' do
    expect(@utils2.concat(nil)).to eq(nil)
    expect(@utils2.concat("hola", -1)).to eq("aloh")
  end

  it 'puede matchear por bloques' do
    expect(@utils2.concat('hola', 45)).to eq(true)
    expect(@utils2.concat('hola', 3)).to eq(true)
    expect(@utils2.concat('hola', 2)).to eq("holahola")
  end

  it 'puede matchear por los mensajes que entiende' do
    expect(@utils3.concat('hola', Persona.new)).to eq('hola Johann Sebastian Mastropiero')
    expect(@utils3.concat('hola', 'mundo')).to eq('holamundo')
    expect(@utils3.concat('hola', 2)).to eq('holahola')
  end

  it 'puede definir multimetodos de clase' do
    expect(StringUtils4.concat('hola', 'mundo')).to eq('holamundo')
    expect(StringUtils4.concat('hola', 2)).to eq('holahola')
  end

  it 'puede usar multimetodos heredados' do
    expect(@utils5.concat('hola', 'mundo')).to eq('mundohola')
    expect(@utils5.concat('-', ['hola', 'mundo'])).to eq('hola-mundo')
    expect(@utils5.concat('hola', 2)).to eq('holahola')
    expect{
      @utils5.concat(3, 3)
    }.to raise_error NoMethodError
  end

end

describe 'ConditionalMethod' do

  before(:each) do
    @conditional_method = ConditionalMethod.new(
        [Conditions.classCondition(String), Conditions.classCondition(Integer)],
        proc { |s, n|
          "some result"
        })
  end

  it 'matchea si tiene la misma cantidad de argumentos que condiciones y condiciones' do
    expect(@conditional_method.matches "a", 5).to be true
  end

  it 'no matchea si no tiene la misma cantidad de argumentos' do
    expect(@conditional_method.matches "a").to be false
  end

  it 'no matchea si no cumple una condicion' do
    expect(@conditional_method.matches "a", "b").to be false
  end

end
