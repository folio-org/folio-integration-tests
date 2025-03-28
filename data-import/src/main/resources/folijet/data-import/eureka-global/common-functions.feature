Feature: Common Functions

  Scenario: Declare common functions
    * def utilFeature = 'classpath:folijet/data-import/eureka-global/import-record.feature'
    * def importHoldingFeature = 'classpath:folijet/data-import/eureka-global/default-import-instance-holding-item.feature@importInstanceHoldingItem'
    * def commonImportFeature = 'classpath:folijet/data-import/eureka-global/common-data-import.feature'
    * def completeExecutionFeature = 'classpath:folijet/data-import/eureka-features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted'
