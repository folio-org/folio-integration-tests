Feature: Create agreement in mod-agreements
  # parameters: agreement
  # returns: agreementId
  Background:
    * url baseUrl

  Scenario: Create agreement
    # External agreement lines point to eHoldings, which is not enabled for this tenant, so skip the remote lookup
    Given path 'erm/sas'
    And param fetchExternalResources = false
    And request agreement
    When method POST
    Then status 201
    * def agreementId = $.id
