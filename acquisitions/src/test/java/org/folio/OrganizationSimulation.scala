package org.folio

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._
import org.apache.commons.lang3.RandomUtils

import scala.concurrent.duration._
import scala.language.postfixOps

class OrganizationSimulation extends Simulation {

  def generateTenantId(): String = {
    val constantString = "testtenant"
    val randomLong = RandomUtils.nextLong
    constantString + randomLong
  }

  val protocol = karateProtocol(
    "/_/proxy/tenants/{tenant}" -> Nil,
    "/_/proxy/tenants/{tenant}/modules" -> Nil,
    "/_/proxy/tenants/{tenant}/install" -> Nil,
    "/acquisitions-units-storage/units" -> Nil,
    "/acquisitions-units-storage/memberships" -> Nil,
    "/acquisitions-units-storage/memberships/{acqMembershipId}" -> Nil,
    "/organizations/organizations" -> Nil,
    "/organizations/organizations/{organizationId}" -> Nil,
    "/users" -> Nil,
  )
  protocol.runner.systemProperty("testTenant", generateTenantId())

  val before = scenario("before")
    .exec(karateFeature("classpath:thunderjet/mod-organizations/organizations-junit.feature"))
  val create = scenario("create")
    .repeat(10) {
      exec(karateFeature("classpath:thunderjet/mod-organizations/organizations.feature"))
    }

  setUp(
    before.inject(atOnceUsers(1))
      .andThen(create.inject(nothingFor(3 seconds), rampUsers(3) during (5 seconds)))
  ).protocols(protocol)

}
