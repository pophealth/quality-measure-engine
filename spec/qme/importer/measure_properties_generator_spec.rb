describe QME::Importer::MeasurePropertiesGenerator do
  it 'should generate measure properties' do
      doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0032/numerator.xml'))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

      measure_json = JSON.parse(File.read(File.join('fixtures', 'entry', 'sample.json')))
      QME::Importer::MeasurePropertiesGenerator.instance.add_measure('0043', QME::Importer::GenericImporter.new(measure_json))

      patient = HealthDataStandards::Import::C32::PatientImporter.instance.parse_c32(doc)

      measure_properties = QME::Importer::MeasurePropertiesGenerator.instance.generate_properties(patient)

      measure_properties['0043']['encounter'].should include(1270598400)
  end
end