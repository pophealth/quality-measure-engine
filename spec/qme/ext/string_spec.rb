describe String do
  it "should be true values" do
    "TRUE".to_boolean.should be_true
    "true".to_boolean.should be_true
    "t".to_boolean.should be_true
    "1".to_boolean.should be_true
  end
  
  it "should be false values" do
    "false".to_boolean.should be_false
  end
  
  it "should return false for non-boolean like values" do
    "bacon".to_boolean.should be_false
  end
end