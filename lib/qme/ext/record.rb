# Extensions to the Record model in health-data-standards to support
# quality measure calculation
class Record

  def procedures_performed
    @procedures_performed = procedures.to_a + immunizations.to_a + medications.to_a
  end  

  def procedure_results
    @procedure_results ||= results.to_a + vital_signs.to_a + procedures.to_a
  end
  
  def laboratory_tests
    @laboratory_tests ||= results.to_a + vital_signs.to_a
  end
  
  def all_meds
    @all_meds ||= medications.to_a + immunizations.to_a
  end
  
  def active_diagnosis
    @active_diagnosis ||= conditions.any_of({:status => 'active'}, {:status => nil}).to_a + 
    social_history.any_of({:status => 'active'}, {:status => nil}).to_a
  end
  
  def inactive_diagnosis
    @inactive_diagnosis ||= conditions.any_of({:status => 'inactive'}).to_a + 
    social_history.any_of({:status => 'inactive'}).to_a
  end
  
  def resolved_diagnosis
    @resolved_diagnosis ||= conditions.any_of({:status => 'resolved'}).to_a + 
    social_history.any_of({:status => 'resolved'}).to_a
  end
  
  def all_problems
    @all_problems ||= conditions.to_a + social_history.to_a
  end
  
  def all_devices
    @all_devices ||= conditions.to_a + procedures.to_a + care_goals.to_a + medical_equipment.to_a
  end
end