Feature: Get entity type field value id by label
  # parameters: entityTypeId, field, label
  # returns: valueId
  # Fields with lookups (organizations, refdata pick lists) are filtered by the selected option's value (id), like in the query builder
  Background:
    * url baseUrl

  Scenario: Get entity type field value id by label
    Given path 'entity-types', entityTypeId, 'field-values'
    And param field = field
    When method GET
    Then status 200
    * def matchingOptions = karate.filter(response.content, function(option) { return option.label == label })
    * match matchingOptions == '#[1]'
    * def valueId = matchingOptions[0].value
