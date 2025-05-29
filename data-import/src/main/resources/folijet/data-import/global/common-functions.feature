Feature: Common Functions

  Scenario: Declare common functions
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def importHoldingFeature = 'classpath:folijet/data-import/global/default-import-instance-holding-item.feature@importInstanceHoldingItem'
    * def commonImportFeature = 'classpath:folijet/data-import/global/common-data-import.feature'
    * def completeExecutionFeature = 'classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted'
    * def exportRecordFeature = 'classpath:folijet/data-import/global/export-record.feature'
    * def createExportMappingProfile = karate.read('classpath:folijet/data-import/global/data-export-profiles.feature@createMappingProfile')
    * def createExportJobProfile = karate.read('classpath:folijet/data-import/global/data-export-profiles.feature@createJobProfile')
    * def samplePath = 'classpath:folijet/data-import/samples/'
    * def updateHoldings = 'classpath:folijet/data-import/features/data-import-integration.feature@UpdateHoldings'
    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'
    * def javaWriteData = Java.type('test.java.WriteData')

