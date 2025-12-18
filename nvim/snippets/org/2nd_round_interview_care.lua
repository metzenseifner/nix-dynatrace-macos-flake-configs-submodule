local agenda = [=[
#+title: Interview Agenda / Structure
#+candidate: <candidate>
#+url: <smartrecruitersurl>

How do you work? Agile progress?
Do you characterize yourself as organized or self-prioritizing?
Are you comfortable working on an existing code base and incrementally improving it over time, accepting a step-by-step approach rather than full code rewrites?

* Preparation Before Interview

** What do we know about the candidate after the 1st round?

Emphasis on desired grade with respect to expertise and anything we need to verify?

#+BEGIN_COMMENT
    - From where?
    - Desires?
    - Thing to check for
    - Seniority Level targeted?
    - availability to start / When to start
    - some do some dont: current salary package (private note in recruiters)
    - cultural fit?
    - Is it possible to sync with hiring manager (whoever ran the first interview)
    - Skill level assessment and related code examples.
#+END_COMMENT

* Ice breaker + Introduction round / Introduce Ourselves (10 min)
- Exchange social pleasantries as applicable i.e. How are you doing?
  Where are you calling from?
- Introduce ourselves to candidate. What is the role of each interviewer?
- Present the headlines of agenda / declare expectations and purpose of
  the second round, making the technical focus explicit.


** Orientation
- Candidate should be familiar with the high-level explanation of Dynatrace
  from first round. At least a rough idea of our domain / what we offer.

*** Team Pitch

*** Where we are now:
(soundbite)

*** Challenges we currently face
(soundbite)

* We'll ask Questions About you (15 min)
- Anything peculiar in the CV to ask ask about?
- High-level segway question: Describe a software project you are proud of and have a technical discussion.
- Any Agile experience or teamwork?
- What kind of process/work model did they have in the past? Team player?

* Technical discussion and real world code example (~40-60 min flexible)

- Questions about project introduced in previous section.
- 2-4 real code examples. Timing depends on how in-depth the technical discussions go.

* Open door for Candidate's Expectations (5 min)
- What do you expect from the job, company, setting...

* Open door for Candidate's Questions (10 min)

- Any open questions...

* Bidirectional Feedback and wrap up (15 min)

- Our turn
- Candidate's turn


** Next Steps (5 min)

What are the next steps after the 2nd round?

- Talent Acquisition will contact you in a week or two regarding the decision of round two. Make an offer (or not).
- What is next step after 2nd round?
  Case Choice
   - Acceptance
   - Rejection
]=]



return {
  s("interview-agenda",
    fmt(agenda, {
        candidate = i(1, "Candidate's Full Name"),
        smartrecruitersurl = i(2, "Smart Recruiters URL")
      },
      { delimiters = "<>" })),
}
