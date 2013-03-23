Feature: Logging
  I want to be able to send log entries to the service
  And see them processed to structured records
  And be able to configure further smart processing on different kinds of records
@wip
  @log @simple
  Scenario: Logging simple events
    Given a simple logging service is running
    When I send log events to the service
    Then I should see processed records in the database
    And the records should have a generated time value
    And the records should have their original origin value
    And the records should have their original message value
