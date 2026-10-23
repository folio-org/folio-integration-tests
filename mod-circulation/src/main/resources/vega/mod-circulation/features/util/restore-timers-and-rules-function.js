// afterScenario hook: restore age-to-lost timers and circulation rules even if a scenario step failed.
// A leftover 1 second age-to-lost timer would age every overdue loan of the tenant (breaking later features).
// Scenario variables used (all optional): sidecarToken, ageToLostResult, ageToLostOriginal, feeChargingResult,
// feeChargingOriginal, timersRestored, originalRulesAsText, rulesRestored
function() {
  var f = 'classpath:vega/mod-circulation/features/util/schedulerUtil.feature';
  var tok = karate.get('sidecarToken');
  if (tok && !karate.get('timersRestored')) {
    var a = karate.get('ageToLostResult');
    if (a && a.currentTimer) {
      if (a.currentTimerCreated) {
        karate.call(f + '@DeleteAgeToLostTimer', { extToken: tok, extTimerId: a.currentTimer.id });
      } else {
        var ao = karate.get('ageToLostOriginal');
        karate.call(f + '@UpdateAgeToLostTimer', { extToken: tok, extTimer: a.currentTimer, extUnit: ao.unit, extDelay: ao.delay });
      }
    }
    var c = karate.get('feeChargingResult');
    if (c && c.currentTimer) {
      if (c.currentTimerCreated) {
        karate.call(f + '@DeleteAgeToLostFeeChargingTimer', { extToken: tok, extTimerId: c.currentTimer.id });
      } else {
        var co = karate.get('feeChargingOriginal');
        karate.call(f + '@UpdateAgeToLostFeeChargingTimer', { extToken: tok, extTimer: c.currentTimer, extUnit: co.unit, extDelay: co.delay });
      }
    }
  }
  var rules = karate.get('originalRulesAsText');
  if (rules && !karate.get('rulesRestored')) {
    karate.call('classpath:vega/mod-circulation/features/util/initData.feature@PutCirculationRules', { extRulesAsText: rules });
  }
}
