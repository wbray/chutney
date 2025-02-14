Feature: Bad Scenario Name
  As a Business Analyst
  I want to be warned about invalid scenario names
  so that I am able to look for better naming

  Background: Prepare Testee
    Given a file named "lint.rb" with:
      """
      $LOAD_PATH << '../../lib'
      require 'chutney'

      linter = Chutney::ChutneyLint.new
      linter.enable %w(BadScenarioName)
      linter.set_linter
      linter.analyze 'lint.feature'
      exit linter.report

      """

  Scenario Outline: Bad Scenario Names
    Given a file named "lint.feature" with:
      """
      Feature: Test
        Scenario: <bad word> something
      """
    When I run `ruby lint.rb`
    Then it should fail with exactly:
      """
      BadScenarioName - You should avoid using words like 'test', 'check' or 'verify' when naming your scenarios to keep them understandable
        lint.feature (2): Test.<bad word> something

      """

    Examples: Words to avoid
      | bad word     |
      | Verifies     |
      | Verification |
      | Verify       |
      | Checks       |
      | Check        |
      | Tests        |
      | Test         |

  Scenario: Valid Example
    Given a file named "lint.feature" with:
      """
      Feature: Test
        Scenario: Suitable Scenario Name
      """
    When I run `ruby lint.rb`
    Then it should pass with exactly:
      """
      """
