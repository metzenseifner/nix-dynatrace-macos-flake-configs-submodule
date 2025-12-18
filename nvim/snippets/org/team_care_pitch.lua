local pitch_care = [=[
  Our team, Team CARE, is part of what we call the *App & Service DeliverY
  (ASDY) Capability*. We enable continuous integration of other teams' software
  products into the Dynatrace Platform following a declarative approach. All
  changes are propagated through Pull Requests.

  Our mission is to support a
  singular source of truth for reproducible state of a given instance on one of
  the various Cloud Service Providers. The code that we write ensures quality
  of deployments and provides transparency of the procedure itself.

  We enable the concept of staging (on the software side as opposed to the
  virtual hardware side) by providing tooling that automates the promotion of
  Dynatrace services from one stage to another.
]=]

return { s("pitch-care",
  fmt(pitch_care, {},
    { delimiters = "<>" }))
}
