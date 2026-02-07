local template = [[
# I feel the intention of this activity is oriented towards personal positive change/growth, and to my benefit.
* Goal Progress
** What is the status of each FY26 goals?
# Put all goals here has subheadings
** What am I most proud of this fiscal year?
** How did I demonstrate Dynatrace values in my work?
** Which 2-3 results or examples do i wish to highlight as part of my Year End Self Evaluation
* Areas of Excellence
** Which skills or qualities helped me excel in this area
** Positive feedback received (2-3 areas of excellence, highlighting my strengths)
* Areas for Improvement
** Areas of my role as Senior Software Engineer I and Team Captain where I see room for improvement
*** Improvement Areas as a Team Captain
*** Improvement Areas as a Senior Software Engineer
** Outlook: name 1-2 skills I would like to develop for next year
** Concrete steps to take to achieve each (1-2 areas of improvement)
*** Technical Domain
* Self-Evaluation FY26
# Concise Summary
# Key questions to answer:
# What progress have you made toward your goals?
# Where did you excel this year?
# What would you like to improve moving forward?

# Here’s a terse version that should be safely under 5000 characters:

# Progress toward my goals

** Increase confidence in promotion tooling
** Engage with Purpose (be explicit with my needs)
** Deepen Kubernetes expertise
** Find comfort in silence
** Tailor leadership styles / improve coaching

# Where I excelled this year
# What did you do technically?
# How did you demonstrate Dynatrace values?
# Highlight strengths from feedback
# What I want to improve next and why (opportunity-oriented)
]]

return {
  s("self-evaluation", fmt(template, {}, {delimiters="<>"}))
}
