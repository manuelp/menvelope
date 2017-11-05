require 'test/unit'
require 'envelope'
require 'date'

class TestEnvelope < Test::Unit::TestCase
  def test_create_single_envelope
    env = Envelope.new("Savings")
    assert_equal("Savings", env.name)
  end

  def test_create_two_envelopes
    evs = []
    evs << Envelope.new("Savings")
    evs << Envelope.new("Loans")

    assert_equal("Savings", evs[0].name)
    assert_equal("Loans", evs[1].name)
  end

  def test_new_envelope_zero_money
    env = Envelope.new("Savings")
    assert_equal(0, env.money)
  end

  def test_add_money
    env = Envelope.new("Savings")

    env.add(150)
    
    assert_equal(150, env.money)
  end
  
  def test_spend_money
    env = Envelope.new("Savings")
    env.add(150)

    env.subtract(30)
    
    assert_equal(120, env.money)
  end

  def test_no_transactions
    env = Envelope.new("Savings")

    assert_equal(0, env.transactions.size)
  end

  def test_print_correctly_a_date
    e = Envelope.new("Savings")

    d = Date.civil(2011, 4, 5)
    d_str = e.date_str(d)
    assert_equal("05/04/2011", d_str)
    
    d = Date.civil(2011, 4, 12)
    d_str = e.date_str(d)
    assert_equal("12/04/2011", d_str)

    d = Date.civil(2011, 11, 12)
    d_str = e.date_str(d)
    assert_equal("12/11/2011", d_str)
  end
  
  def test_record_transactions
    env = Envelope.new("Savings")

    env.add(140)
    env.subtract(20)
    
    assert_equal(2, env.transactions.size)
    assert_equal("[#{env.date_str(Date.today)}]added:140", env.transactions[0])
    assert_equal("[#{env.date_str(Date.today)}]subtracted:20", env.transactions[1])
  end

  def test_no_subenvelopes
    env = Envelope.new("Savings")

    assert_equal(0, env.subenvelopes.size)
  end

  def test_add_subenvelope
    env = Envelope.new("Savings")
    env.add(130)
    env.add_envelope("House")

    assert_equal(130, env.money)
    assert_equal(1, env.subenvelopes.size)
    assert_equal("House", env.subenvelopes["House"].name)
    assert_equal(0, env.subenvelopes["House"].money)
    assert_equal(0, env.subenvelopes["House"].transactions.size)
  end

  def test_subenvelope_parent
    env = Envelope.new("Savings")
    env.add(130)
    env.add_envelope("House")

    assert_equal(130, env.money)
    assert_equal(1, env.subenvelopes.size)
    assert_equal(env, env.subenvelopes["House"].parent)
  end
  
  def test_total_money_with_subenvelope
    env = Envelope.new("Savings")
    env.add(1500)
    env.add_envelope("House")

    env.move(500, "House")

    assert_equal(1500, env.money)
    assert_equal(500, env.subenvelopes["House"].money)
    assert_equal("[#{env.date_str(Date.today)}]subtracted:500", env.transactions[1])    
    assert_equal("[#{env.date_str(Date.today)}]added:500", env.subenvelopes["House"].transactions[0])    
  end

  def test_total_money_adding_directly_to_subenvelope
    env = Envelope.new("Savings")
    env.add(1500)
    env.add_envelope("House")

    env.subenvelopes["House"].add(500)

    assert_equal(2000, env.money)
  end

  def test_print
    env = Envelope.new("Savings")
    env.add(1500)
    env.add_envelope("House")
    env.move(100, "House")

    out = """- Savings: 1500 (1400)
  - House: 100 (100)
"""
    assert_equal(out, env.to_s)
  end
end

