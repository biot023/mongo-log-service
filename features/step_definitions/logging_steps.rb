Given( /^a simple logging service is running$/ ) do
  run_service
end

Given( /^a logging service with a time processor$/ ) do
  run_service( :time_processor )
end

Given( /^a logging service with a ruby\-safe processor$/ ) do
  run_service( :ruby_safe_processor )
end

Given( /^a logging service with a hashes processor$/ ) do
  run_service( :hashes_processor )
end

Given( /^a logging service with a labelled hash processor$/ ) do
  run_service( :labelled_hashes_processor )
end

Given( /^a logging service with a rails controller processor$/ ) do
  run_service( :rails_controller_processor )
end

Given( /^a logging service with a session id processor$/ ) do
  run_service( :session_id_processor )
end

When( /^I send events to the service$/ ) do
  @sent, @processed = send_log_events
end

When(/^I send events with ruby objects in them to the service$/) do
  @sent, @processed = send_log_events( :with_ruby_objects )
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
  @processed[7].tap do |doc|
    doc["parameters"].should == { "controller" => "sessions", "action" => "new" }
  end
  @processed[8].tap do |doc|
    doc["parameters"].should == {
      "controller" => "items",
      "id"         => "999876-Rupcycled-Bangle-Red",
      "action"     => "show"
    }
  end
end

Then( /^the extracted labelled hashes should no longer be in the records' messages$/ ) do
  [ 1, 2, 4, 5, 6, 7, 8 ].each do |index|
    @processed[index]["message"].should_not match( /:\{\}/ )
  end
end

Then( /^the rails controller records should have their controllers in their own field$/ ) do
  { 7 => "SessionsController", 8 => "ItemsController", 9 => "IpnsController"
  }.each do |index, controller|
    @processed[index]["controller"].should == controller
    @processed[index]["message"].should_not match( /#{ controller }/ )
  end
end

Then( /^the rails controller records should have their actions in their own field$/ ) do
  { 7 => "new", 8 => "show", 9 => "paypal_ipn"
  }.each do |index, action|
    @processed[index]["action"].should == action
    @processed[index]["message"].should_not match( /##{ action }/ )
  end
end

Then( /^the rails controller records should have their HTTP verbs in their own field$/ ) do
  { 7 => "GET", 8 => "GET", 9 => "POST"
  }.each do |index, http_verb|
    @processed[index]["http_verb"].should == http_verb
    @processed[index]["message"].should_not match( /##{ http_verb }/ )
  end
end

Then( /^the rails controller records should have their IP addresses in their own field$/ ) do
  { 7 => "86.16.61.59", 8 => "157.56.92.147", 9 => "173.0.81.1"
  }.each do |index, ip_address|
    @processed[index]["ip_address"].should == ip_address
    @processed[index]["message"].should_not match( /##{ ip_address }/ )
  end
end

Then( /^the records with session ids should have them in their own field$/ ) do
  { 7 => "b298650560db8de031b590eeacb00511",
    8 => "b14fb89ab48b9f144b76faa0402219a4",
    9 => "cd02b9d27ebaa801c289791c47bfb524"
  }.each do |index, session_id|
    @processed[index]["session_id"].should == session_id
    @processed[index]["message"].should_not match( /Session ID:/ )
    @processed[index]["message"].should_not match( /##{ session_id }/ )
  end
end

Then( /^any ruby objects should have been safely quoted$/ ) do
  # Would have thrown an error if they hadn't
end
