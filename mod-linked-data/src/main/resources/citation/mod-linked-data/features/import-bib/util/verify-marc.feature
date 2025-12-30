Feature: MARC Derived Records

  Background:
    * def getMarcCall = call getDerivedMarc { resourceId:  '#(instanceResourceId)' }
    * def fields = getMarcCall.response.parsedRecord.content.fields

  @C983190
  Scenario: Verify MARC 600 derived from HUB
    * match fields contains { 600: { subfields: [ { a: "Dracontius, Blossius Aemilius" }, { d: "active 5th century" }, { l: "German & Latin" }, { t: "Medea" }, { v: "Drama" }, { x: "Parodies, imitations, etc" } ], ind1: " ", ind2: " " } }
