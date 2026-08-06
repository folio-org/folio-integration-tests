Feature: Common Functions

  Scenario: Declare common functions
    * def utilFeature = 'classpath:promin/data-import/global/import-record.feature'
    * def importHoldingFeature = 'classpath:promin/data-import/global/default-import-instance-holding-item.feature@importInstanceHoldingItem'
    * def commonImportFeature = 'classpath:promin/data-import/global/common-data-import.feature'
    * def getCompletedJobFeature = 'classpath:promin/data-import/global/get-completed-job-execution.feature'
    * def completeExecutionFeature = 'classpath:promin/data-import/global/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted'
    * def exportRecordFeature = 'classpath:promin/data-import/global/export-record.feature'
    * def createExportMappingProfile = karate.read('classpath:promin/data-import/global/data-export-profiles.feature@createMappingProfile')
    * def createExportJobProfile = karate.read('classpath:promin/data-import/global/data-export-profiles.feature@createJobProfile')
    * def samplePath = 'classpath:promin/data-import/samples/'
    * def updateHoldings = 'classpath:promin/data-import/features/data-import-integration.feature@UpdateHoldings'
    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'
    * def javaWriteData = Java.type('test.java.WriteData')

