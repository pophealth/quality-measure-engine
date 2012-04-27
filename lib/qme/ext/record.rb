# Extensions to the Record model in health-data-standards to support
# quality measure calculation
class Record
  extend ActiveSupport::Memoizable
  
  def procedures_performed
    procedures.to_a + immunizations.to_a
  end
  
  def procedure_results
    results.to_a + vital_signs.to_a + procedures.to_a
  end
  
  def laboratory_tests
    results.to_a + vital_signs.to_a
  end
  
  def all_meds
    medications.to_a + immunizations.to_a
  end
  
  def active_diagnosis
    conditions.any_of({:status => 'active'}, {:status => nil}).to_a + 
    social_history.any_of({:status => 'active'}, {:status => nil}).to_a
  end
  
  def inactive_diagnosis
    conditions.any_of({:status => 'inactive'}, {:status => nil}).to_a + 
    social_history.any_of({:status => 'inactive'}, {:status => nil}).to_a
  end
  
  def resolved_diagnosis
    conditions.any_of({:status => 'resolved'}, {:status => nil}).to_a + 
    social_history.any_of({:status => 'resolved'}, {:status => nil}).to_a
  end
  
  def all_problems
    conditions.to_a + social_history.to_a
  end
  
  def all_devices
    conditions.to_a + procedures.to_a + care_goals.to_a + medical_equipment.to_a
  end
  
  memoize :procedure_results
  memoize :laboratory_tests
  memoize :all_meds
  memoize :active_diagnosis
  memoize :inactive_diagnosis
  memoize :resolved_diagnosis
  memoize :all_problems
  memoize :all_devices
end