local make_personal_development_view_for = function(name)
  return {
    description = string.format("%s's Growth View", name),
    types = {
      {
        type = "tags",
        match = string.format('+TYPE="Initiative"&BY="%s"', name, name),
        org_agenda_overriding_header = string.format("# %s's Initiatives", name),
      },
      {
        type = "tags",
        match = string.format('+TYPE="COMMITMENT"&BY="%s"|TYPE="Commitment"&BY="%s"', name, name),
        org_agenda_overriding_header = string.format("# %s's Commitments", name),
      },
      {
        type = "tags",
        match = string.format('+TYPE="Gap"&BY="%s"', name),
        org_agenda_overriding_header = string.format("# %s's Gaps", name),
      },
      {
        type = "tags_todo",
        match = string.format('+TYPE="Wish"&BY="%s"', name),
        org_agenda_overriding_header = string.format("# %s's Wishes / Desires", name),
      },
      {
        type = "tags",
        match = string.format('+TYPE="Goal"&BY="%s"', name),
        org_agenda_overriding_header = string.format("# %s's Goals", name),
      },
      {
        type = "tags",
        match = string.format('+TYPE="Feedback"&FOR="%s"&TODO="DONE"', name),
        org_agenda_overriding_header = string.format("# %s's Feedback Given", name),
      },
      {
        type = "tags_todo",
        match = string.format('+TYPE="Feedback"&FOR="%s"', name),
        org_agenda_overriding_header = string.format("# %s's Feedback Ungiven", name),
      },
      {
        type = "tags",
        match = string.format('+TYPE="Observation"&FOR="%s"', name),
        org_agenda_overriding_header = string.format("# Observations of %s's ", name),
      },
      {
        type = "tags",
        match = string.format('+TYPE="Follow-up"&FOR="%s"', name, name),
        org_agenda_overriding_header = string.format("# %s's Follow-ups", name),
      },
      {
        type = "tags",
        match = string.format('+TYPE="Self-assessment"&BY="%s"', name),
        org_agenda_overriding_header = string.format("# %s's Self-assessment", name),
      },
    },
  }
end

return {
  make_personal_development_view_for = make_personal_development_view_for,
}
