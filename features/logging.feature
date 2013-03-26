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

  @log @unlabelled @hash
  Scenario: Logging events with a hashes processor
    Given a logging service with a hashes processor
    When I send events to the service
    Then I should see processed records in the database
    And the records should have their original miscellaneous values
    And the records should have their hash keys and values in their bodies
    And the extracted hashes should no longer be in the records' messages

  @log @labelled @hash
  Scenario: Logging events with a labelled hash processor
    Given a logging service with a labelled hash processor
    When I send events to the service
    Then I should see processed records in the database
    And the records should have their original miscellaneous values
    And the records' messages should still have their unlabelled hashes
    And the records should have their labelled hashes extracted to labelled sub-hashes
    And the extracted labelled hashes should no longer be in the records' messages

  @log @sql
  Scenario: Logging events with a rails controller processor
    Given a logging service with a rails controller processor
    When I send events to the service
    Then I should see processed records in the database
    And the records should have their original miscellaneous values
    And the rails controller records should have their controllers in their own field
    And the rails controller records should have their actions in their own field
    And the rails controller records should have their HTTP verbs in their own field
    And the rails controller records should have their IP addresses in their own field
@wip
  @log @session_id
  Scenario: Logging events with a session id processor
    Given a logging service with a session id processor
    When I send events to the service
    Then I should see processed records in the database
    And the records should have their original miscellaneous values
    And the records with session ids should have them in their own field

  @log @email
  Scenario: Logging events with an email processor
    Given Pending
