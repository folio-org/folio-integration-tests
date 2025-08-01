function fn() {

  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  var env = karate.env;

  // The "testTenant" property could be specified during test runs
  var testTenant = karate.properties['testTenant'];
  var testTenantId = karate.properties['testTenantId'];

  var config = {
    baseUrl: 'http://localhost:8000',
    edgeUrl: 'http://localhost:9000',
    ftpUrl: 'ftp://ftp.ci.folio.org',
    ftpPort:  21,
    ftpUser: 'folio',
    ftpPassword: 'Ffx29%pu',
    admin: {tenant: 'diku', name: 'diku_admin', password: 'admin'},
    prototypeTenant: 'diku',
    consortiaSystemUserName: 'consortia-system-user',

    kcClientId: 'folio-backend-admin-client',
    kcClientSecret: karate.properties['clientSecret'] || 'SecretPassword',

    testTenant: testTenant,
    testTenantId: testTenantId ? testTenantId : (function() { return java.util.UUID.randomUUID() + '' })(),
    testAdmin: {tenant: testTenant, name: 'test-admin', password: 'admin'},
    testUser: {tenant: testTenant, name: 'test-user', password: 'test'},

    // define global features
    createAdditionalUser: karate.read('classpath:common/eureka/create-additional-user.feature'),
    getUserIdByUsername: karate.read('classpath:common/eureka/users.feature'),
    login: karate.read('classpath:common/login.feature'),
    loginRegularUser: karate.read('classpath:common/login.feature'),
    loginAdmin: karate.read('classpath:common/login.feature'),
    eurekaLogin: read('classpath:common-consortia/eureka/initData.feature@Login'),
    dev: karate.read('classpath:common/dev.feature'),
    variables: karate.read('classpath:global/variables.feature'),

    // common reusable features
    resourceExists: karate.read('classpath:thunderjet/common/resource-exists.feature'),
    deleteResource: karate.read('classpath:thunderjet/common/delete-resource.feature'),
    updateResource: karate.read('classpath:thunderjet/common/update-resource.feature'),
    verifyResourceAuditEvents: karate.read('classpath:thunderjet/common/verify-resource-audit-events.feature'),

    // acquisitions units
    createAcqUnit: karate.read('classpath:thunderjet/mod-orders/reusable/acq-unit.feature@CreateAcqUnit'),
    assignUserToAcqUnit: karate.read('classpath:thunderjet/mod-orders/reusable/acq-unit.feature@AssignUserToAcqUnit'),
    deleteUserFromAcqUnit: karate.read('classpath:thunderjet/mod-orders/reusable/acq-unit.feature@DeleteUserFromAcqUnit'),

    // consortia variables
    variablesCentral: karate.read('classpath:thunderjet/consortia/variables/variablesCentral.feature'),
    variablesUniversity: karate.read('classpath:thunderjet/consortia/variables/variablesUniversity.feature'),

    // finances
    backdateFY: karate.read('classpath:thunderjet/mod-finance/reusable/backdateFY.feature'),
    createFiscalYear: karate.read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature'),
    createFund: karate.read('classpath:thunderjet/mod-finance/reusable/createFund.feature'),
    createRestrictedFund: karate.read('classpath:thunderjet/mod-finance/reusable/createRestrictedFund.feature'),
    createFundWithParams: karate.read('classpath:thunderjet/mod-finance/reusable/createFundWithParams.feature'),
    createBudget: karate.read('classpath:thunderjet/mod-finance/reusable/createBudget.feature'),
    createTransaction: karate.read('classpath:thunderjet/mod-finance/reusable/createTransaction.feature'),
    createEncumbrance: karate.read('classpath:thunderjet/mod-finance/reusable/createEncumbrance.feature'),
    createPayment: karate.read('classpath:thunderjet/mod-finance/reusable/createPayment.feature'),
    createPendingPayment: karate.read('classpath:thunderjet/mod-finance/reusable/createPendingPayment.feature'),
    createLedger: karate.read('classpath:thunderjet/mod-finance/reusable/createLedger.feature'),
    createExpenseClass: karate.read('classpath:thunderjet/mod-finance/reusable/createExpenseClass.feature'),
    createBudgetExpenseClass: karate.read('classpath:thunderjet/mod-finance/reusable/createBudgetExpenseClass.feature'),
    rollover: karate.read('classpath:thunderjet/mod-finance/reusable/rollover.feature'),
    verifyReleasedEncumbrance: karate.read('classpath:thunderjet/mod-finance/reusable/verify-released-encumbrance.feature'),

    // inventory
    createItem: karate.read('classpath:thunderjet/consortia/reusable/createItem.feature'),
    createHolding: karate.read('classpath:thunderjet/consortia/reusable/createHolding.feature'),
    createHoldingSource: karate.read('classpath:thunderjet/consortia/reusable/createHoldingSource.feature'),
    createInstance: karate.read('classpath:thunderjet/consortia/reusable/createInstance.feature'),
    createInstanceWithHrid: karate.read('classpath:thunderjet/consortia/reusable/createInstanceWithHrid.feature'),
    createInstanceStatus: karate.read('classpath:thunderjet/consortia/reusable/createInstanceStatus.feature'),
    createInstanceType: karate.read('classpath:thunderjet/consortia/reusable/createInstanceType.feature'),
    createInstitution: karate.read('classpath:thunderjet/consortia/reusable/createInstitution.feature'),
    createLibrary: karate.read('classpath:thunderjet/consortia/reusable/createLibrary.feature'),
    createCampus: karate.read('classpath:thunderjet/consortia/reusable/createCampus.feature'),
    createLocation: karate.read('classpath:thunderjet/consortia/reusable/createLocation.feature'),
    createLoanType: karate.read('classpath:thunderjet/consortia/reusable/createLoanType.feature'),
    createMaterialType: karate.read('classpath:thunderjet/consortia/reusable/createMaterialType.feature'),
    createServicePoint: karate.read('classpath:thunderjet/consortia/reusable/createServicePoint.feature'),
    moveHolding: karate.read('classpath:thunderjet/consortia/reusable/moveHolding.feature'),
    moveItem: karate.read('classpath:thunderjet/consortia/reusable/moveItem.feature'),
    updateHoldingOwnership: karate.read('classpath:thunderjet/consortia/reusable/updateHoldingOwnership.feature'),
    updateItemOwnership: karate.read('classpath:thunderjet/consortia/reusable/updateItemOwnership.feature'),
    shareInstance: karate.read('classpath:thunderjet/consortia/reusable/shareInstance.feature'),
    updateHridSettings: karate.read('classpath:thunderjet/consortia/reusable/updateHridSettings.feature'),
    verifyOwnership: karate.read('classpath:thunderjet/consortia/reusable/verifyOwnership.feature'),

    // orders
    createOrder: karate.read('classpath:thunderjet/mod-orders/reusable/create-order.feature'),
    updateOrder: karate.read('classpath:thunderjet/mod-orders/reusable/update-order.feature'),
    openOrder: read('classpath:thunderjet/mod-orders/reusable/open-order.feature'),
    unopenOrder: read('classpath:thunderjet/mod-orders/reusable/unopen-order.feature'),
    unopenOrderDeleteHoldings: read('classpath:thunderjet/mod-orders/reusable/unopen-order-delete-holdings.feature'),
    deleteInstance: read('classpath:thunderjet/mod-orders/reusable/delete-instance.feature'),
    closeOrder: read('classpath:thunderjet/mod-orders/reusable/close-order.feature'),
    cancelOrder: read('classpath:thunderjet/mod-orders/reusable/cancel-order.feature'),
    deleteOrder: read('classpath:thunderjet/mod-orders/reusable/delete-order.feature'),
    getOrderLine: karate.read('classpath:thunderjet/mod-orders/reusable/get-order-line.feature'),
    createOrderLine: karate.read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature'),
    createOrderLineWithInstance: karate.read('classpath:thunderjet/mod-orders/reusable/create-order-line-with-instance.feature'),
    changeOrderLineInstanceConnection: karate.read('classpath:thunderjet/mod-orders/reusable/change-order-line-instance-connection.feature'),
    updateOrderLine: karate.read('classpath:thunderjet/mod-orders/reusable/update-order-line.feature'),
    validateCompositeOrders: karate.read('classpath:thunderjet/mod-orders/reusable/validate-composite-orders.feature'),
    verifyPoLineReceiptStatus: karate.read('classpath:thunderjet/mod-orders/reusable/verify-po-lines.feature@VerifyPoLineReceiptStatus'),
    createTitle: karate.read('classpath:thunderjet/mod-orders/reusable/create-title.feature@title'),
    createTitleForInstance: karate.read('classpath:thunderjet/mod-orders/reusable/create-title.feature@instance'),
    createPiece: karate.read('classpath:thunderjet/mod-orders/reusable/create-piece.feature'),
    createPiecesBatch: karate.read('classpath:thunderjet/mod-orders/reusable/create-pieces-batch.feature'),
    createPieceWithHoldingOrLocation: karate.read('classpath:thunderjet/mod-orders/reusable/create-piece-with-holding-or-location.feature'),
    updatePiecesBatchStatus: karate.read('classpath:thunderjet/mod-orders/reusable/update-pieces-batch-status.feature'),
    claimPieces: karate.read('classpath:thunderjet/mod-orders/reusable/claim-pieces.feature'),
    receivePieceWithHolding: karate.read('classpath:thunderjet/mod-orders/reusable/receive-piece-with-holding.feature'),
    verifyPieceAuditEvents: karate.read('classpath:thunderjet/mod-orders/reusable/verify-piece.feature@VerifyPieceAuditEvents'),
    verifyPieceReceivingStatus: karate.read('classpath:thunderjet/mod-orders/reusable/verify-piece.feature@VerifyPieceReceivingStatus'),
    verifyEncumbranceStatus: karate.read('classpath:thunderjet/mod-orders/reusable/verify-encumbrance.feature@VerifyEncumbranceTransactionStatus'),

    // invoices
    getInvoice: karate.read('classpath:thunderjet/mod-invoice/reusable/get-invoice.feature'),
    createInvoice: read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature'),
    createInvoiceLine: read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature'),
    approveInvoice: read('classpath:thunderjet/mod-invoice/reusable/approve-invoice.feature'),
    payInvoice: read('classpath:thunderjet/mod-invoice/reusable/pay-invoice.feature'),
    cancelInvoice: read('classpath:thunderjet/mod-invoice/reusable/cancel-invoice.feature'),
    verifyInvoiceLine: read('classpath:thunderjet/mod-invoice/reusable/verify-invoice-line.feature'),

    // organizations
    createAcqUnit: karate.read('classpath:thunderjet/mod-organizations/reusable/create-acq-unit.feature'),
    createOrganization: karate.read('classpath:thunderjet/mod-organizations/reusable/create-organization.feature'),

    // data export
    createIntegrationDetails: karate.read('classpath:thunderjet/mod-data-export-spring/reusables/create-integration-details.feature'),
    verifyExportJobFile: karate.read('classpath:thunderjet/mod-data-export-spring/reusables/verify-export-job-file.feature'),
    resendExportJobFile: karate.read('classpath:thunderjet/mod-data-export-spring/reusables/resend-export-job-file.feature'),

    // mosaic
    checkOrder: karate.read('classpath:thunderjet/mod-mosaic/reusable/check-order.feature'),
    checkOrderLine: karate.read('classpath:thunderjet/mod-mosaic/reusable/check-order-line.feature'),

    // edge-orders
    checkEndpoint: karate.read('classpath:thunderjet/edge-orders/reusable/check-endpoint.feature'),
    
    // gobi
    cleanupOrderData: karate.read('classpath:thunderjet/mod-gobi/reusable/cleanup-order-data.feature'),

    // define global functions
    uuid: function () {
      return java.util.UUID.randomUUID() + ''
    },

    uuids: function (n) {
      var list = [];
      for (var i = 0; i < n; i++) {
        list.push(java.util.UUID.randomUUID() + '');
      }
      return list;
    },

    random: function (max) {
      return Math.floor(Math.random() * max)
    },

    randomMillis: function() {
      return java.lang.System.currentTimeMillis() + '';
    },

    random_string: function() {
      var text = "";
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      for (var i = 0; i < 5; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
      return text;
    },
    getCurrentYear: function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var sdf = new SimpleDateFormat('yyyy');
      var date = new java.util.Date();
      return sdf.format(date);
    },
    getCurrentDate: function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var sdf = new SimpleDateFormat('yyyy-MM-dd');
      var date = new java.util.Date();
      return sdf.format(date);
    },

    getYesterday: function() {
      var LocalDate = Java.type('java.time.LocalDate');
      var localDate = LocalDate.now().minusDays(1);
      var formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");
      var formattedString = localDate.format(formatter);
      return localDate.format(formatter);
    },

    isoDate: function() {
      // var dtf = java.time.format.DateTimeFormatter.ISO_INSTANT;
      var dtf = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'");
      var date = java.time.LocalDateTime.now(java.time.ZoneOffset.UTC);
      return dtf.format(date);
    },

    pause: function(millis) {
      var Thread = Java.type('java.lang.Thread');
      Thread.sleep(millis);
    },

    // line: file content
    // replacements: array of objects {regex: 'regex', newString: 'newString'}
    replaceRegex: function(line, replacements) {
      for (var i = 0; i < replacements.length; i++) {
        var regex = replacements[i].regex;
        var newString = replacements[i].newString;
        line = line.replace(new RegExp(regex, "gm"), newString);
      }
      return line;
    },

    orWhereQuery: function(field, values) {
        var orStr = ' or ';
        var string = '(' + field + '=(' + values.map(x => '"' + x + '"').join(orStr) + '))';

        return string;
    }
  };

  // Create 100 functions for uuid generation
  var rand = function(i) {
    karate.set("uuid"+i, function() {
      return java.util.UUID.randomUUID() + '';
    });
  }
  karate.repeat(100, rand);

  if (env == 'dev') {
    // UI: http://localhost:3000/
    config.checkDepsDuringModInstall = 'false';
    config.baseKeycloakUrl = 'http://keycloak.eureka:8080';
    config.kcClientId = 'supersecret';
    config.kcClientSecret = karate.properties['clientSecret'] || 'supersecret';
  } else if (env == 'snapshot-2') {
    // UI: https://folio-etesting-snapshot2-diku.ci.folio.org/
    config.baseUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot2-keycloak.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot2-kong.ci.folio.org:8000';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'snapshot') {
    // UI: https://folio-etesting-snapshot-diku.ci.folio.org/
    config.baseUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-snapshot-keycloak.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-snapshot-kong.ci.folio.org:8000';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'sprint') {
    // UI: https://folio-etesting-snapshot-diku.ci.folio.org/
    config.baseUrl = 'https://folio-etesting-sprint-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-sprint-keycloak.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-sprint-kong.ci.folio.org:8000';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'cypress') {
    // UI: https://folio-etesting-snapshot-diku.ci.folio.org/
    config.baseUrl = 'https://folio-etesting-cypress-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-etesting-cypress-keycloak.ci.folio.org';
    config.edgeUrl = 'https://folio-etesting-cypress-kong.ci.folio.org:8000';
    config.admin = {
      tenant: 'supertenant',
      name: 'testing_admin',
      password: 'admin'
    }
  } else if (env == 'rancher') {
    // UI at https://folio-edev-thunderjet-diku.ci.folio.org/
    config.baseUrl = 'https://folio-edev-thunderjet-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-thunderjet-keycloak.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-thunderjet-edge.ci.folio.org';
    config.prototypeTenant= 'diku'
  } else if (env == 'rancher-2nd') {
    // UI at https://folio-edev-thunderjet-2nd-consortium.ci.folio.org/
    config.checkDepsDuringModInstall = 'false';
    config.baseUrl = 'https://folio-edev-thunderjet-2nd-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-thunderjet-2nd-keycloak.ci.folio.org';
    config.edgeUrl = 'https://folio-edev-thunderjet-2nd-edge.ci.folio.org';
    config.prototypeTenant= 'diku'
    config.admin = {
      tenant: 'diku',
      name: 'diku_admin',
      password: 'admin'
    }
  } else if (env == 'rancher-consortia') {
    // UI at https://folio-edev-thunderjet-consortium.ci.folio.org/
    config.baseUrl = 'https://ecs-folio-edev-thunderjet-kong.ci.folio.org';
    config.baseKeycloakUrl = 'https://folio-edev-thunderjet-keycloak.ci.folio.org';
    config.edgeUrl = 'https://ecs-folio-edev-thunderjet-edge.ci.folio.org';
    config.prototypeTenant= 'consortium'
    config.admin = {
      tenant: 'consortium',
      name: 'consortium_admin',
      password: 'admin'
    }
  } else if(env == 'folio-testing-karate') {
    // Used to run nightly karate tests in Jenkins
    config.baseUrl = '${baseUrl}';
    config.baseKeycloakUrl = '${baseKeycloakUrl}';
    config.edgeUrl = '${edgeUrl}';
    config.admin = {
      tenant: '${admin.tenant}',
      name: '${admin.name}',
      password: '${admin.password}'
    }
    config.kcClientId = '${clientId}',
    config.kcClientSecret = '${clientSecret}'
    config.prototypeTenant = '${prototypeTenant}';
    karate.configure('ssl',true);
  } else if (env != null && env.match(/^ec2-\d+/)) {
    // Config for FOLIO CI "folio-integration" public ec2- dns name
    config.baseUrl = 'http://' + env + ':8000';
    config.edgeUrl = 'http://' + env + ':8000';
    config.admin = {
      tenant: 'supertenant',
      name: 'admin',
      password: 'admin'
    }
  }
  return config;
}
