Given( /^a simple logging service is running$/ ) do
  run_service
end

When( /^I send log events to the service$/ ) do
  send_log_events
end
