raise "Need atleast one argument." if ARGV[0].nil?

class FracHash < Hash

  def initialize
    set_to_default
  end

  def reset!
    set_to_default
  end

  def print_mixed_number
    sign = self[:den] < 0 ? "-" : ""

    whole = self[:whole]
    num = self[:num]
    den = self[:den].abs

    if whole == 0
      ratio = num.to_f/den
      if ratio == 0
        return "0"
      elsif ratio == 1
        return "#{sign}1"
      elsif ratio > 1 && (num%den == 0)
        return "#{sign}#{ratio.to_i.to_s}"
      elsif ratio > 1
        "#{sign}#{ratio.to_i}_#{num%den}/#{den}"
      else
        "#{sign}#{num}/#{den}"
      end
    elsif num == 0
     "#{sign}#{whole}"
    else
     "#{sign}#{whole}_#{num}/#{den}"
    end
  end



  private

  def set_to_default
    self[:whole] = 0
    self[:num]  = 0
    self[:den]  = 1
    self
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

    def lcm(f1, f2)
      f1[:den] * f2[:den]
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

  hh = FracHash.new

  toggle_list = {
      ignore_whitespace: false,
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
        else
          (hh[:den]*=-1)
        end
        toggle_list[:pointer] = :whole
      when /\d/
        pointer_val = hh[toggle_list[:pointer]]
        hh[toggle_list[:pointer]] = (toggle_list[:pointer] == :den && s[ii-1]&.match(/\//)) ? char.to_i * pointer_val : pointer_val * 10 + char.to_i
        toggle_list[:ignore_whitespace] = false
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
        toggle_list[:ignore_whitespace] && next
        operator = toggle_list[:operator]
        if operator == :add || operator == :subtract
          hhdup = hh.dup
          (operator == :subtract) && hhdup[:den]*=-1
          sum_stack.push(hhdup)
        else
          sum_stack.push(FracHashCalculator.public_send(toggle_list[:operator] , sum_stack.pop, hh))
        end
        (ii == string_size) && next
        hh.reset!
        toggle_list[:ignore_whitespace] = true
        toggle_list[:is_mixed_value] = false
    end
  end
  sum = FracHashCalculator.add(sum_stack[0], sum_stack[1])
  puts sum.print_mixed_number
end

solve_equation(ARGV[0].strip)
