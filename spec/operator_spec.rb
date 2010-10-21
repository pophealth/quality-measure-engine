require 'json'
require 'measure'

describe Engine::TimePeriod do
  it 'should extract the value and units from a Hash' do
    period_json = '{"val": "1", "unit":"year"}'
    hash = JSON.parse(period_json)
    period = Engine::TimePeriod.new({}, hash)
    period.evaluate.should eql(365*24*60*60)
  end
end

describe Engine::Minus do
  it 'should support two val/unit args' do
    args_json = '[{"val": "1", "unit":"year"}, {"val": "1", "unit":"year"}]'
    arr = JSON.parse(args_json)
    minus = Engine::Minus.new({}, arr)
    minus.evaluate.should eql(0)
  end
  it 'should support one val/unit arg and one reference' do
    args_json = '["@param", {"val": "2", "unit":"second"}]'
    arr = JSON.parse(args_json)
    minus = Engine::Minus.new({"param"=>4}, arr)
    minus.evaluate.should eql(2)
  end
  it 'should support one val/unit arg and one explicit number' do
    args_json = '["4", {"val": "2", "unit":"second"}]'
    arr = JSON.parse(args_json)
    minus = Engine::Minus.new({"param"=>2}, arr)
    minus.evaluate.should eql(2)
  end
end

describe Engine::Operator do
  it 'should be able to perform minus on years' do
    args_json = '{"$minus": [{"val": "1", "unit":"year"}, {"val": "1", "unit":"year"}]}'
    arr = JSON.parse(args_json)
    minus = Engine::Operator.new({}).parse(arr)
    minus.evaluate.should eql(0)
  end
  it 'should be able to perform minus on seconds' do
    args_json = '{"$minus": [{"val": "3", "unit":"second"}, {"val": "1", "unit":"second"}]}'
    arr = JSON.parse(args_json)
    minus = Engine::Operator.new({}).parse(arr)
    minus.evaluate.should eql(2)
  end
end