require 'date'

class Envelope
  attr_reader :name, :transactions, :subenvelopes
  attr_accessor :parent
  
  # Create a new envelope with the given name and 0 money
  def initialize(name)
    @name = name
    @money = 0
    @transactions = []
    @subenvelopes = {}
    @parent = nil
  end

  # Add an amount of money to this envelope, and track the transaction
  def add(amount)
    @money += amount
    transactions << "[#{date_str(Date.today)}]added:#{amount}"
  end

  # Subtract an amount of money to this envelope, and track the transaction
  def subtract(amount)
    @money -= amount
    transactions << "[#{date_str(Date.today)}]subtracted:#{amount}"
  end

  # Return the date in the "dd/MM/yyyy" format
  def date_str(date)
    result = ""
    if date.day > 9 then
      result += "#{date.day}"
    else
      result += "0#{date.day}"
    end
    result += "/"
    if date.month > 9 then
      result += "#{date.month}"
    else
      result += "0#{date.month}"
    end
    result += "/#{date.year}"
  end

  # Add a new subenvelope with the given name
  def add_envelope(name)
    subenvelope = Envelope.new(name)
    subenvelope.parent = self
    @subenvelopes[name] = subenvelope
  end

  # Move an amount of money from this envelope to the specified
  # subenvelope (the move is tracked as an adding transaction to the
  # subenvelope).
  def move(amount, subenvelope)
    subtract(amount)
    @subenvelopes[subenvelope].add(amount)
  end

  # Return the total amount of money contained in this envelope + all subenvelopes
  def money
    tot = @money
    tot += subenvelopes_money
    tot
  end

  # Return the amount of money contained in all subenvelopes
  def subenvelopes_money
    tot = 0
    subenvelopes.each {|key, val| tot += val.money}
    tot
  end

  # Return a string representing the current envelope:
  # * name of the envelope
  # * total amount of money contained in this envelope plus all
  # subenvelopes
  # * actual amount of money contained in this envelope only
  def to_s
    result = "- #{name}: #{money} (#{@money})\n"
    subenvelopes.each {|key, val| result += "  #{val.to_s}"}
    result
  end
end
