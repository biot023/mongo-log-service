Given( /^a simple logging service is running$/ ) do
  run_service
end

When( /^I send log events to the service$/ ) do
  @sent, @processed = send_log_events
end

Then( /^I should see processed records in the database$/ ) do
  @processed.size.should == @sent.size
end

Then( /^the records should have their original miscellaneous values$/ ) do
  [ @sent, @processed ].transpose.each do |odoc, tdoc|
    tdoc["server"].should == odoc["server"]
    tdoc["level"].should == odoc["level"]
  end
end

Then( /^the records should have their original message value$/ ) do
  [ @sent, @processed ].transpose.each do |odoc, tdoc|
    tdoc["message"].should_not be_nil
    tdoc["message"].should_not be_empty
    tdoc["message"].should == odoc["message"]
  end
end

Then( /^records with time values keep the originals$/ ) do
  [ @sent, @processed ].transpose.each do |odoc, tdoc|
    next if ! odoc["time"]
    tdoc["time"].strftime( "%Y%m%d%H%M%S" ).should == odoc["time"].strftime( "%Y%m%d%H%M%S" )
  end
end

Then(/^records without time values get given them$/) do
  [ @sent, @processed ].transpose.each do |odoc, tdoc|
    next if odoc["time"]
    tdoc.should have_key( "time" )
    tdoc["time"].should be > ( Time.now - 60 )
  end
end
