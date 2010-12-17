module QME
  module Importer
    # A base class for all the additional diabetes-related measures to use when they need an importer
    #
    # Extracts information relevant to calculating the Diabetic Eye Exam (NQF 0055) from HITSP C32 documents
    # The following XPath expressions are used
    #
    # Finding encounter elements in the Encounters section. This is used to find both acute inpatient and
    # non‐acute inpatient, outpatient, or ophthalmology encounters
    #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.127']/cda:entry/cda:encounter
    #
    # For finding procedures anywhere in the document (used to find eye exam procedure)
    #    //cda:procedure[cda:templateId/@root='2.16.840.1.113883.10.20.1.29']
    #
    # For finding coded medications within the substanceAdministration when searching for medications indicative
    # of diabetes
    #    ./cda:consumable/cda:manufacturedProduct/cda:manufacturedMaterial/cda:code 
    #
    # For finding problems or conditions in the Diagnosis List section(used to find diabetes, 
    # gestational diabetes, steroid induced_diabetes, and polycystic ovaries)
    #    //cda:section[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.103']/cda:entry/
    #cda:act/cda:entryRelationship/cda:observation
    class DiabetesMeasureBase < MeasureBase

      def parse_diabetes_measure(doc, measure_info)
      end

    end
  end
end