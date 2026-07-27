# mod-service-interaction — API integration tests

Karate corpus for [mod-service-interaction](https://github.com/folio-org/mod-service-interaction):
dashboards and widgets, number generators, reference data and settings, admin
actions, RFC 8693 attestation, the web-toolkit listing grammar, and the Okapi
`_tenant` lifecycle.

The corpus is **authored against the legacy Grails module** (repository
`master`) and runs **unchanged against the Spring Boot rewrite**, so the same
suite can exercise both deployments and expose any functional difference
between them.

## Running

The suite builds on the shared `common` and `testrail-integration` submodules,
so build them alongside it:

```bash
# against the legacy Grails module (the default)
mvn test -pl common,testrail-integration,mod-service-interaction \
    -Dkarate.env=legacy -DbaseUrl=http://legacy-host:8080

# against the Spring Boot rewrite
mvn test -pl common,testrail-integration,mod-service-interaction \
    -Dkarate.env=port -DbaseUrl=http://port-host:8081

# a single feature
mvn test -pl common,testrail-integration,mod-service-interaction \
    -Dtest=ModServiceInteractionTest#numberGenerationTest -DfailIfNoTests=false
```

| Property | Default | Meaning |
| --- | --- | --- |
| `karate.env` | `legacy` | `legacy` or `port` — selects the deployment defaults and the expected answer for the registered deviations below |
| `baseUrl` | `http://localhost:8080` (legacy) / `:8081` (port) | Where the module (or a gateway in front of it) answers |
| `okapiUrl` | `http://localhost:9130` | Value of the `X-Okapi-Url` header handed to the module |
| `testTenant` | a fresh `testtenant<random>` per run | Tenant the suite provisions and works in |
| `moduleId` | `mod-service-interaction-4.4.0` / `-5.0.0` | `module_to` sent on the tenant job |
| `purgeOnExit` | `false` | Drop the test tenant's schema after the run |
| `federation` | `false` | Enable the widget-definition federation scenario (needs a real gateway) |

## Environment contract

The suite talks to the module the way Okapi does, and nothing else is required:

* **The module and its database.** Any deployment that answers on `baseUrl` —
  a container, a locally started jar, or the module behind Okapi/Kong.
* **No login, mod-users, mod-permissions or keycloak.** The module derives the
  acting FOLIO user from `X-Okapi-User-Id` and the dashboard admin override
  from `X-Okapi-Permissions`; the suite sets both directly, exactly as a
  gateway would. A "user" here is therefore just a UUID, which lets every
  scenario start from a user with zero dashboards.
* **A tenant the suite may own.** `servint-junit.feature` enables the module
  for `testTenant` through `POST /_/tenant` with `loadReference` and
  `loadSample`; several features additionally provision throwaway tenants to
  assert enable-time behaviour exactly.

If the module under test sits behind an Okapi with `mod-authtoken` enabled, the
gateway will overwrite the identity headers — run the suite against the module
directly (the normal parity setup), or against a gateway without the auth
filter.

## Running the parity comparison

1. Deploy the legacy module and the rewrite, each with its own database.
2. Run the suite twice, once per `karate.env`, ideally with the same
   `-DtestTenant=…` value so the two databases end up holding comparable data.
3. Compare the two Karate reports (`target/karate-reports*/`). Every scenario
   should pass on both sides; the only per-deployment differences the corpus
   allows are the registered deviations below, and they are asserted
   explicitly rather than tolerated.
4. For data integrity, diff the two tenant schemas after the run (the suite
   leaves them in place unless `-DpurgeOnExit=true`).

## Registered deviations

These are the only points where the corpus expects a different answer per
deployment. Each is a documented decision in the module's migration dossier
(`docs/migration/wire-compat-deviations.md` in the module repository), not a
test workaround.

| Id | Surface | Legacy | Rewrite |
| --- | --- | --- | --- |
| D-26 | `_tenant` interface | 1.2 — enable answers 201, `DELETE /_/tenant` purges, `POST /_/tenant/disable` disables | 2.0 — every job is a `POST /_/tenant` answering 204; purge needs an explicit `purge` flag |
| D-27 | `POST /servint/dashboard` | 200 | 201 |
| D-2 | `POST /servint/widgets/definitions` | 201 (creates) | 405 (never declared) |
| D-3 | `GET /servint/widgets/instances/{unknown}` | 500 | 404 |
| D-20 | `PUT …/displayData` with a foreign `dashId` | state-dependent (not pinned) | 422 `dashboard.id.mismatch` |
| D-21 | Attestation `kid` header | the usage string (`extApp`) | the signing key record id |
| D-22 | Malformed JSON body | 4xx/5xx, not pinned | 400 `malformed.json` |
| D-23 | Missing `x-okapi-tenant` | 500-class | 400 `text/plain` |
| D-24 | Duplicate generator code | 500 | 409 `integrity.violation` |
| D-25 | Unknown refdata value in a body | 201, value silently dropped | 400 `unknown.refdata` |
| D-28, D-30 | Malformed or uncoercible filter values | 500 | 200 with the clause dropped |

## Deviation matrix

Every deviation in the module's dossier, and what this corpus does about it.
A deviation that is neither asserted nor listed here would be a hole in the
parity verdict.

| Id | Status here | Note |
| --- | --- | --- |
| D-2, D-3, D-20 … D-28, D-30 | **Asserted** | The table above; each is expected per deployment, never tolerated |
| D-19 | **Port only** | `listing-grammar.feature` pins the flat N-ary disjunction on the port; legacy's top-two pairing was never measured, so only the status is asserted there |
| D-4 | **Designed around** | Positional assertions always carry an explicit `sort`; unsorted listings are asserted with `contains only` |
| D-6, D-7, D-8 | **Status only** | The 422/400 triggers are identical; only the envelope shape differs, and the corpus asserts the status |
| D-12 | **Not exercised** | Sub-route listings ignore kiwt params on the port. No scenario puts more than ten rows behind one, so the fixed page size never bites |
| D-32 | **Partly** | The top-level empty-right-side drop is asserted as parity on both sides; the greedy absorption *inside* a compound and the `!(…)` 500 are not exercised |
| D-5, D-13, D-14 | **Partly** | Attestation key reuse, one refdata domain lookup and the stats envelope are pinned; the cross-tenant cache, the full domain registry and per-listing envelope extras are not |
| D-1 | **Not exercised** | `my-widgets` is dead in legacy and undeclared in the port — nothing to compare |
| D-9, D-10, D-11 | **Not exercised** | Request-binding differences (partial PUT nulls, bare-string refdata). Adding them would re-pin known differences rather than test parity |
| D-15, D-16, D-17 | **Structural** | Covered indirectly by `tenant-lifecycle` and by schema diffing after the run, not by a scenario |
| D-18 | **Not exercised** | Exotic truthy seeding values (`"1"`, `"yes"`) diverge by framework contract; Okapi only ever sends `"true"`/`"false"`, which the corpus uses |
| D-29 | Retired | No longer a deviation — legacy-identical since M9 |
| D-31, D-33, D-34 | **Wire only** | Oversized filter values, repeated `term`, malformed percent-escapes: container-level behaviour that an HTTP client library normalises. Pinned by the module's own wire probes, deliberately out of scope here |

## Coverage

| Feature | What it pins |
| --- | --- |
| `tenant-lifecycle` | enable, idempotent upgrade, purge, disable, explicit-purge guard, operation-status routes |
| `reference-data-seeding` | the two seeding buckets and their triggers, the nine default generators, the check-digit vocabulary, idempotency |
| `refdata` | category CRUD, the domain/property lookup, term/stats on the lookup |
| `app-settings` | setting CRUD and the listing envelope |
| `numgen-management` | generator and sequence CRUD, owner snippet, derived `maximumCheck`, cascade delete, 64-bit values |
| `number-generation` | `getNextNumber`: auto-creation, formats, prefixes, output and pre-checksum templates, all six check-digit algorithms, `lastUsedYear` |
| `numgen-limits` | `HitMaximum` / `OverThreshold` warnings, `MaxReached` refusal and its rollback |
| `numgen-year-reset` | the `${current_year}` token, lazy reset on a stale year, the validation guard, the timer sweep |
| `dashboard-management` | auto-provisioning, creator grants and weights, widget summaries, cascade delete, the admin-only index |
| `dashboard-access` | the view < edit < manage hierarchy, `my-access`, the admin override |
| `dashboard-user-management` | grant/edit/delete items, weight and default rules, ignored duplicate and self grants, the users render |
| `dashboard-user-ordering` | bulk reordering, the single-default invariant, whole-request rejection |
| `dashboard-display-data` | layout read/write by access level, the `dashId` identity guard |
| `widget-types-definitions` | the type catalog, the local definition render, the permission-free `dashboard` interface endpoint, federation (opt-in) |
| `widget-instances` | dashboard-derived authorization, weight auto-assignment, the instance render, the admin-only index |
| `admin-actions` | `triggerTypeImport`, `triggerTypeImportClean`, `ensureDisplayData` |
| `attestation` | token envelope, JWS header, claim set, subject fallback, key reuse |
| `listing-grammar` | operators, `is [not] null`, compounds, paging and its aliases, the stats envelope, term/match, sort and filter tolerance |
| `error-envelopes` | missing tenant, malformed JSON, duplicate keys, unknown refdata, validation failures, unknown ids |
