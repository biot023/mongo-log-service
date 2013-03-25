Feature: Logging
  I want to be able to send log entries to the service
  And see them processed to structured records
  And be able to configure further smart processing on different kinds of records

  @log @simple
  Scenario: Logging simple events
    Given a simple logging service is running
    When I send events to the service
    Then I should see processed records in the database
    And the records should have their original miscellaneous values
    And the records should have their original message value

  @log @time
  Scenario: Logging events with a time processor
    Given a logging service with a time processor
    When I send events to the service
    Then I should see processed records in the database
    And records with original time values should keep those
    And records without original time values should be given them
@wip
  @log @unlabelled @hash
  Scenario: Logging events with a hashes processor
    Given a logging service with a hashes processor
    When I send events to the service
    Then I should see processed records in the database
    And all records should have time values
    And the records should have their original miscellaneous values
    And the records should have their hash values extracted to a sub-hash
    And the extracted hashes should no longer be in the records' messages

  @log @labelled @hash
  Scenario: Logging events with a labelled hash processor
    Given Pending

  @log @sql
  Scenario: Logging events with a SQL processor
    Given Pending

  @log @email
  Scenario: Logging events with an email processor
    Given Pending
