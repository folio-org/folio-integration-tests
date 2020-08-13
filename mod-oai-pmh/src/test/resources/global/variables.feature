  # This must be called in background of scenarios that are using configuration templates
  # variables can then be redefined before loading templates

  Feature: Global variables

    Scenario: mod-configuration variables
    #=====Default configuration values=====
    #general
      * def enableOaiServiceConfig = 'true'
    #technical
      * def maxRecordsPerResponseConfig = '50'
    #behavior
      * def errorsProcessingConfig = '200'
      * def deletedRecordsSupportConfig = 'persistent'
      * def suppressedRecordsProcessingConfig = 'false'
