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
    @active_diagnosis ||= (conditions.select {|entry| entry.status == 'active' || entry.status.nil? || entry.ordinality == 'principal'}) + 
      (social_history.select {|entry| entry.status == 'active' || entry.status.nil? })
  end
  
  def inactive_diagnosis
    @inactive_diagnosis ||= (conditions.select {|entry| entry.status == 'inactive'}) + 
    (social_history.select {|entry| entry.status == 'inactive'})
  end
  
  def resolved_diagnosis
    @resolved_diagnosis ||= (conditions.select {|entry| entry.status == 'resolved'}) + 
    (social_history.select {|entry| entry.status == 'resolved'})
  end
  
  def all_problems
    @all_problems ||= conditions.to_a + social_history.to_a
  end
  
  def all_devices
    @all_devices ||= conditions.to_a + procedures.to_a + care_goals.to_a + medical_equipment.to_a
  end
end