Feature: Ensure agreement organization role exists
  # parameters: roleLabel, roleValue
  # Adds the role to the 'SubscriptionAgreementOrg.Role' pick list unless it is already present
  Background:
    * url baseUrl

  Scenario: Ensure agreement organization role exists
    Given path 'erm/refdata'
    And param filters = 'desc==SubscriptionAgreementOrg.Role'
    When method GET
    Then status 200
    And match $ == '#[1]'
    * def category = response[0]
    * def roleExists = karate.filter(category.values, function(v) { return v.value == roleValue }).length > 0
    * if (roleExists) karate.abort()

    * def existingValues = karate.map(category.values, function(v) { return { id: v.id } })
    * def newValues = karate.append(existingValues, { label: roleLabel, value: roleValue })
    Given path 'erm/refdata', category.id
    And request { id: '#(category.id)', values: '#(newValues)' }
    When method PUT
    Then status 200
    And match $.values[*].value contains roleValue
