Given( /^a simple logging service is running$/ ) do
  run_service
end

Given( /^a logging service with a time processor$/ ) do
  run_service( :time_processor )
end

Given( /^a logging service with a hashes processor$/ ) do
  run_service( :hashes_processor )
end

Given(/^a logging service with a labelled hash processor$/) do
  run_service( :labelled_hashes_processor )
end

When( /^I send events to the service$/ ) do
  @sent, @processed = send_log_events
end

Then( /^I should see processed records in the database$/ ) do
  @processed.size.should == @sent.size
end

Then( /^the records should have their original miscellaneous values$/ ) do
  [ @sent, @processed ].transpose.each do |odoc, tdoc|
    tdoc["server"].should == odoc["server"]
    tdoc["level"].should == odoc["level"]
    tdoc["type"].should == odoc["type"]
  end
end

Then( /^the records should have their original message value$/ ) do
  [ @sent, @processed ].transpose.each do |odoc, tdoc|
    tdoc["message"].should_not be_nil
    tdoc["message"].should_not be_empty
    tdoc["message"].should == odoc["message"]
  end
end

Then( /^records with original time values should keep those$/ ) do
  [ @sent, @processed ].transpose.each do |odoc, tdoc|
    next if ! odoc["time"]
    tdoc["time"].strftime( "%Y%m%d%H%M%S" ).should == odoc["time"].strftime( "%Y%m%d%H%M%S" )
  end
end

Then( /^records without original time values should be given them$/ ) do
  [ @sent, @processed ].transpose.each do |odoc, tdoc|
    next if odoc["time"]
    tdoc.should have_key( "time" )
    tdoc["time"].should be > ( Time.now - 60 )
  end
end

Then( /^the records should have their hash keys and values in their bodies$/ ) do
  @processed[1].tap do |doc|
    doc["some"].should == "issues"
  end
  @processed[2].tap do |doc|
    doc["Nested"].should == { "Issues" => { "In" => "Here" } }
  end
  @processed[3].tap do |doc|
    doc["Here"].should == "are"
    doc["for"].should == { "1" => { "2" => "consider" } }
  end
end

Then( /^the extracted hashes should no longer be in the records' messages$/ ) do
  @processed.each do |doc|
    doc["message"].should_not match( /\{|\}/ )
  end
end

Then( /^the records' messages should still have their unlabelled hashes$/ ) do
  @processed[3].tap do |doc|
    doc["message"].should match( /\{/ )
  end
end

Then( /^the records should have their labelled hashes extracted to labelled sub\-hashes$/ ) do
  @processed[1].tap do |doc|
    doc["have"].should == { "some" => "issues" }
  end
  @processed[2].tap do |doc|
    doc["are"].should == { "Nested" => { "Issues" => { "In" => "Here" } } }
  end
  @processed[4].tap do |doc|
    doc["hate"].should == { "Oblong" => "Biscuits" }
  end
  @processed[5].tap do |doc|
    doc["disliking"].should == { "nested" => { "hashes" => { "On" => "principle" } } }
  end
  @processed[6].tap do |doc|
    doc["two"].should == { "Hashes" => "Within" }
    doc["within"].should == { "my" => "message" }
  end
end

Then( /^the extracted labelled hashes should no longer be in the records' messages$/ ) do
  [ 1, 2, 4, 5, 6 ].each do |index|
    @processed[index]["message"].should_not match( /:\{\}/ )
  end
end
