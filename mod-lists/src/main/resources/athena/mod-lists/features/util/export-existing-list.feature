Feature: Export an existing list to CSV
  # parameters: listId, fields
  # returns: exportId, csvHeader (array of column labels), csvRows (raw data lines, UTF-8 BOM stripped, empty lines skipped)
  Background:
    * url baseUrl

  Scenario: Export an existing list to CSV
    Given path 'lists', listId, 'exports'
    And request fields
    When method POST
    Then status 201
    And match $.status == 'IN_PROGRESS'
    * def exportId = $.exportId

    Given path 'lists', listId, 'exports', exportId
    And retry until response.status == 'SUCCESS'
    When method GET
    Then status 200

    Given path 'lists', listId, 'exports', exportId, 'download'
    When method GET
    Then status 200
    * def JavaString = Java.type('java.lang.String')
    * def csvText = new JavaString(responseBytes, 'UTF-8').replace('﻿', '') + ''
    * def csvLines = karate.filter(csvText.split(/\r?\n/), function(line) { return line.trim().length > 0 })
    # Values containing spaces or other special characters are quoted, so split the header respecting quotes
    * def parseCsvLine =
      """
      function(line) {
        var cells = [];
        var cell = '';
        var inQuotes = false;
        for (var i = 0; i < line.length; i++) {
          var ch = line.charAt(i);
          if (inQuotes && ch == '"' && line.charAt(i + 1) == '"') { cell += '"'; i++; }
          else if (ch == '"') inQuotes = !inQuotes;
          else if (ch == ',' && !inQuotes) { cells.push(cell); cell = ''; }
          else cell += ch;
        }
        cells.push(cell);
        return cells;
      }
      """
    * def csvHeader = parseCsvLine(csvLines[0])
    * def csvRows = karate.filter(csvLines, function(line, index) { return index > 0 })
