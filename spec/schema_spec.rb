require 'json'

describe JSON, 'All JSON Schemas' do
  it 'should conform to JSON Schema' do
    schema = File.open('schema/schema.json', 'rb'){|f| JSON.parse(f.read)}
    Dir.glob('schema/*.json').each do |schema_file|
      if schema_file != 'schema/schema.json' # Don't check the schema itself
       data = File.open(schema_file, 'rb'){|f| JSON.parse(f.read)}
       JSON::Schema.validate(data, schema)
      end
    end
  end
end

describe JSON, 'Result Example' do 
  it 'should conform to the schema defined' do
    schema = File.open('schema/result.json', 'rb'){|f| JSON.parse(f.read)}
    data = File.open('fixtures/result_example.json', 'rb'){|f| JSON.parse(f.read)}
    JSON::Schema.validate(data, schema)
  end
end
