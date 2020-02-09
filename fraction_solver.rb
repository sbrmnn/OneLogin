raise "Equation not supplied." if ARGV[0].nil?

class FracHash < Hash

  def initialize
    reset!
  end

  def reset!
    self[:whole] = 0
    self[:num]  = 0
    self[:den]  = 1
    self
  end

  def print_mixed_number
    sign = self[:den] < 0 ? "-" : ""
    whole = self[:whole]
    num = self[:num]
    den = self[:den].abs
    case whole
      when 0
        ratio = num.to_f/den
        if ratio == 0
          "0"
        elsif ratio >= 1
          (num%den == 0) ? "#{sign}#{ratio.to_i}" : "#{sign}#{ratio.to_i}_#{num%den}/#{den}"
        else
          "#{sign}#{num}/#{den}"
        end
      else
        (num == 0) ? "#{sign}#{whole}" : "#{sign}#{whole}_#{num}/#{den}"
    end
  end
end

class FracHashCalculator

  def self.add(f1, f2)
    convert_to_fraction(f1)
    convert_to_fraction(f2)
    return (simplify_fraction(f1[:num], f1[:den]) || simplify_fraction(f2[:num], f2[:den])) if f1.nil? || f2.nil?
    den = lcm(f1, f2)
    num = (f1[:num] * (den/f1[:den])) + (f2[:num] * (den/f2[:den]))
    simplify_fraction(num, den)
  end

  def self.divide(f1, f2)
    convert_to_fraction(f1)
    convert_to_fraction(f2)
    return (simplify_fraction(f1[:num], f1[:den]) || simplify_fraction(f2[:num], f2[:den])) if f1.nil? || f2.nil?
    den = f1[:den] * f2[:num]
    num = f1[:num] * f2[:den]
    simplify_fraction(num, den)
  end

  def self.multiply(f1, f2)
    convert_to_fraction(f1)
    convert_to_fraction(f2)
    return (simplify_fraction(f1[:num], f1[:den]) || simplify_fraction(f2[:num], f2[:den])) if f1.nil? || f2.nil?
    den = f1[:den] * f2[:den]
    num = f1[:num] * f2[:num]
    simplify_fraction(num, den)
  end

  def self.subtract(f1, f2)
    convert_to_fraction(f1)
    convert_to_fraction(f2)
    return (simplify_fraction(f1[:num], f1[:den]) || simplify_fraction(f2[:num], f2[:den])) if f1.nil? || f2.nil?
    den = lcm(f1, f2)
    num = (f1[:num] * (den/f1[:den])) - (f2[:num] * (den/f2[:den]))
    simplify_fraction(num, den)
  end

  def self.lcm(f1, f2)
    f1[:den] * f2[:den]
  end

  class << self

    private

    def convert_to_fraction(f)
      return nil if f.nil?
      raise ZeroDivisionError if f[:den] == 0
      f[:num] =  (f[:whole] * f[:den].abs) + f[:num]
      f[:whole] = 0
      f
    end

    def gcd(a, b)
      return a if b.zero?
      gcd b, a % b
    end

    def simplify_fraction(num, den, f=FracHash.new)
      factor = gcd den, num
      f[:den] = den/factor
      f[:num] = num/factor
      f
    end
  end
end

def solve_equation(s)
  return puts s if (s.size == 1 && s.match(/\d/)) || (s.size == 2 && s[0].match(/-/) && s[1].match(/\d/))

  hh = FracHash.new

  toggle_list = {
    is_mixed_value: false,
    pointer: :whole,
    operator: :add
  }
  
  sum_stack = []

  string_size = s.size

  for ii in (0..string_size)
    char = s[ii]
    case char
      when /-/
        if s[ii+1]&.match(/\s/)
          sum_stack = [FracHashCalculator.add(sum_stack[0], sum_stack[1])]
          (toggle_list[:operator] = :subtract)
        end
        hh[:den]*=-1
        toggle_list[:pointer] = :whole
      when /\d/
        pointer_val = hh[toggle_list[:pointer]]
        num_after_fraction_symbol = (toggle_list[:pointer] == :den && s[ii-1]&.match(/\//))
        hh[toggle_list[:pointer]] =  num_after_fraction_symbol ? char.to_i * pointer_val : pointer_val * 10 + char.to_i
      when /\+/
        sum_stack = [FracHashCalculator.add(sum_stack[0], sum_stack[1])]
        toggle_list[:operator] = :add
        toggle_list[:pointer] = :whole
      when /\*/
        toggle_list[:pointer] = :whole
        toggle_list[:operator] = :multiply
      when /\//
        if s[ii+1]&.match(/\s/)
          toggle_list[:operator] = :divide
          toggle_list[:pointer] = :whole
          next
        end
        unless toggle_list[:is_mixed_value]
          hh[:num] = hh[:whole]
          hh[:whole] = 0
        end
        toggle_list[:pointer] = :den
      when /_/
        toggle_list[:pointer] = :num
        toggle_list[:is_mixed_value] = true
      else
        (s[ii]&.match(/\s/) && !s[ii-1]&.match(/\d/)) && next
        operator = toggle_list[:operator]
        if operator == :add || operator == :subtract
          sum_stack.push(hh.dup)
        else
          sum_stack.push(FracHashCalculator.public_send(toggle_list[:operator] , sum_stack.pop, hh))
        end
        (ii == string_size) && next
        hh.reset!
        toggle_list[:is_mixed_value] = false
    end
  end
  sum = FracHashCalculator.add(sum_stack[0], sum_stack[1])
  puts sum.print_mixed_number
end

solve_equation(ARGV[0].strip)
