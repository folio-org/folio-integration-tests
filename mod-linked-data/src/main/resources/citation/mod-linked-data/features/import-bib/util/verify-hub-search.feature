Feature: Hub Search
  @C983155
  Scenario Outline: Verify hub is indexed.
    * def query = '<query>'
    * def searchCall = call searchLinkedDataHub
    * match searchCall.response.totalRecords == 1
    * def actualLabel = searchCall.response.content[0].label
    * def actualId = searchCall.response.content[0].id
    * match actualLabel == '<expectedLabel>'
    * match actualId != null

    Examples:
      | query                                        | expectedLabel                                                            |
      | label = "Dracontius, Blossius Aemilius"      | Dracontius, Blossius Aemilius. active 5th century. Medea. German & Latin |
      | label = "Medea"                              | Dracontius, Blossius Aemilius. active 5th century. Medea. German & Latin |
