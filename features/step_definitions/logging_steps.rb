Given( /^a simple logging service is running$/ ) do
  run_service
end

When( /^I send log events to the service$/ ) do
  @sent, @processed = send_log_events
end

Then( /^I should see processed records in the database$/ ) do
  @processed.size.should == @sent.size
end
