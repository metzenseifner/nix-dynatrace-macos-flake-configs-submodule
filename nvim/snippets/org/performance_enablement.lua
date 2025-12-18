local end_year_review_template = [[
*** TODO Prep for Year End Review. Add Progress Reports for each Goal.
    :PROPERTIES:
    :BY: Matthaeus Huber
    :TYPE: Performance Enablement
    :END:
     - Add your progress information as comments to your goals in SuccessFactors.
     - Think about your accomplishments since your last review (in this case, in 2024).
     - Include examples of when you embodied our Culture Code Values.
       “Innovate with Passion,” “Engage with Purpose,” or “Win with Integrity.” These comments will be available in your Year End form.

     *What you should know*
     - Personal Feedback Talks with your Team Captain: We will use SuccessFactors to store _commitments_ you and your team captain have discussed _together_. i.e. Entering them on your own does not make sense.
       A budget of 25€.

     *How can you find help to prepare*
     - Guidance for All Dynatracers*: https://dynatrace.sharepoint.com/sites/Learn-and-Develop/SitePages/Goal-Setting-Performance-Enablement.aspx
     - Find Specific Guidance for Your Role(s) or Special Engagements

     *What you can expect*
     - Expect in February invitation for formal review with your team captain and dev manager.

     *What to expect*
     Dev Manager will reach out with a formal Year End Review invitation, which is a 3-person meeting—your Team Captain, Dev Manager, and you—to discuss your personal development.
]]
return {
  s("End Year Review Task Template", { fmt(end_year_review_template, {}, { delimiters = "<>" }) })
}
