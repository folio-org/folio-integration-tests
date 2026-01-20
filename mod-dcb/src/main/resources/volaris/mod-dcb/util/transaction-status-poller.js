function(config) {
  const maxRetries = config.maxRetries || 10;
  const interval = config.interval || 500;
  karate.log('[pollUntil] Configuration: ' + JSON.stringify(config));
  let response = null;
  for (let i = 0; i < maxRetries; i++) {
    const args = {
      path: config.path,
      baseUrl: config.baseUrl,
      key: config.apikey,
      startDate: config.startDate,
      endDate: getCurrentUtcDate(),
      pageSize: config.pageSize || 50,
      pageNumber: config.pageNumber || 0,
    };

    karate.log('[pollUntil] Args: ' + JSON.stringify(args));
    const result = karate.call("classpath:volaris/mod-dcb/reusable/poll-transaction-statuses.feature@GetTransactionStatuses", args);
    response = result.response;
    if (config.expectedRecords == response.totalRecords) {
      karate.log('[pollUntil] Success on retry: ' + (i + 1));
      return response;
    }

    karate.log('[Poller] Retry ' + (i + 1) + ' failed. Waiting ' + interval + 'ms');
    java.lang.Thread.sleep(interval);
  }

  karate.fail('[Poller] Timeout: Condition not met after ' + maxRetries + ' retries.');
}
