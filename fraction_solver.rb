require 'byebug'
raise "Need atleast one argument." if ARGV[0].nil?

class FractionHash < Hash

  def initialize
    set_to_default
  end

  def reset!
    set_to_default
  end

  def print_proper_fraction
    remainder = self[:num]%self[:den]
    if remainder == 0
      "#{self[:num]}"
    else
      "#{self[:num]/self[:den]}_#{self[:num]%self[:den]}/#{self[:den]}"
    end
  end

  private

  def set_to_default
    self[:whole] = 0
    self[:num]  = 0
    self[:den]  = 1
    self[:proper] = false
    self
  end
end



class FractionHashCalculator

  def self.add(f1, f2)
    convert_to_improper(f1)
    convert_to_improper(f2)
    den = lcm(f1, f2)
    num = (f1[:num] * (den/f1[:den])) + (f2[:num] * (den/f2[:den]))
    simplify_fraction(num, den)
  end

  def self.subtract(f1, f2)
    convert_to_improper(f1)
    convert_to_improper(f2)
    den = lcm(f1, f2)
    num = (f1[:num] * (den/f1[:den])) - (f2[:num] * (den/f2[:den]))
    simplify_fraction(num, den)
  end

  def self.multiply(f1, f2)
    convert_to_improper(f1)
    convert_to_improper(f2)

    f = FractionHash.new

    num = f1[:num] * f2[:num]
    den = f1[:den] * f2[:den]
    factor = gcd den, num

    f[:num] = num/factor
    f[:den] = den/factor
    f
  end

  def self.divide(f1, f2)
    convert_to_improper(f1)
    convert_to_improper(f2)

    f = FractionHash.new

    num = f1[:num] * f2[:den]
    den = f1[:den] * f2[:num]
    factor = gcd den, num

    f[:num] = num/factor
    f[:den] = den/factor
    f
  end

  def self.simplify_fraction(num, den)
    factor = gcd den, num
    f = FractionHash.new
    f[:num] = num/factor
    f[:den] = den/factor
    f
  end

  def self.convert_to_improper(f)
    raise ZeroDivisionError if f[:den] == 0
    f[:num] =  (f[:whole] * f[:den].abs) + f[:num]
    f[:whole] = 0
    f[:proper] = false
    f
  end

  def self.lcm(f1, f2)
    f1[:den] * f2[:den]
  end

  def self.gcd(a, b)
    return a if b.zero?
    gcd b, a % b
  end
end

def solve_equation(s)
  hh = FractionHash.new
  toggle_list = {ignore_whitespace: false}
  sum_stack = []
  pointer = :whole
  operator = :add
  string_size = s.size
  for ii in (0..string_size)
    char = s[ii]
    case char
      when /-/
        s[ii+1]&.match(/\s/) ? (operator = :subtract) : (hh[:den]*=-1)
        pointer = :whole
      when /\d/
        pointer_val = hh[pointer]
        hh[pointer] = (pointer == :den && s[ii-1]&.match(/\//)) ? char.to_i * pointer_val : pointer_val * 10 + char.to_i
        toggle_list[:ignore_whitespace] = false
      when /\+/
        sum_stack = [FractionHashCalculator.add(sum_stack[0], sum_stack[1])] if sum_stack.size == 2
        operator = :add
        pointer = :whole
      when /\*/
        pointer = :whole
        operator = :multiply
      when /\//
        if s[ii+1]&.match(/\s/)
          operator = :divide
          pointer = :whole
          next
        elsif !hh[:proper]
          hh[:num] = hh[:whole]
          hh[:whole] = 0
        end
        pointer = :den
      when /_/
        pointer = :num
        hh[:proper] = true
      else
        next if toggle_list[:ignore_whitespace]
        if operator == :add
          sum_stack.push(hh.dup)
        else
          pop_val = sum_stack.pop || FractionHash.new
          sum_stack.push(FractionHashCalculator.public_send(operator , pop_val, hh))
        end
        next if ii == string_size
        hh.reset!
        toggle_list[:ignore_whitespace] = true
    end
  end
  sum = (sum_stack.size == 2) ? FractionHashCalculator.add(sum_stack[0], sum_stack[1]) : sum_stack[0]
  puts sum.print_proper_fraction
end

solve_equation(ARGV[0].strip)
