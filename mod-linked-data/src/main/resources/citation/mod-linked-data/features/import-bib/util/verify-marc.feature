Feature: MARC Derived Records

  Background:
    * def getMarcCall = call getDerivedMarc { resourceId:  '#(instanceResourceId)' }
    * def fields = getMarcCall.response.parsedRecord.content.fields
    * print fields

  @C983190
  Scenario: Verify MARC 600 derived from HUB
    * match fields contains { 600: { subfields: [ { a: "Dracontius, Blossius Aemilius" }, { d: "active 5th century" }, { l: "German & Latin" }, { t: "Medea" }, { v: "Drama" }, { x: "Parodies, imitations, etc" } ], ind1: " ", ind2: " " } }

  @C594517
  Scenario: Verify MARC 100 has $9
    * match fields contains { 100: { subfields: [ { a: "Edgell, David L." }, { c: "Sr." }, { d: "1938-" }, { e: "author" }, { q: "David Lee" }, { 0: "http://id.loc.gov/authorities/n87116094" }, { 4: "aut" }, { 9: '#(authorityIdOfn87116094)' } ], ind1: " ", ind2: " " }}
