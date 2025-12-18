return {
  s("event-object-access", fmt([[
    // Note that it is often the case that the event object contains key members with dots in their names, which cannot be accessed using dot ref syntax.
    // Instead, use event().get("a.b")
    {{ event().get("a.b") }}
    // OR
    //{{ event()["a.b"] }}
  ]], {}, { delimiters = "<>" })),
  s("event-object-access-with-default", fmt([[
    // Note that it is often the case that the event object contains key members with dots in their names, which cannot be accessed using dot ref syntax.
    // Instead, use event().get("a.b")
    {{ event().get("a.b", "myDefaultValueUponUndefined") }}
    // OR
    //{{ event()["a.b"], "myDefaultValueUponUndefined" }}
  ]], {}, { delimiters = "<>" })),
  s("event-object-access-example", fmt([[
    {{
    # Note that and token is case sensitive, true and false are case sensitive
    event().get("type", "UNDEFINED") == "phasedrelease.majorPhase.subPhase.checkInstallation.check"
      and event().get("status", "UNDEFINED") == "finished"
      and event().get("stateChanged", false) == true
      and event().get("stateResult", "UNDEFINED") == "KeepWaiting"
      and event().get("slackNotificationChannelId", "") != ""
    }}
  ]], {}, { delimiters = "<>" }))
}
