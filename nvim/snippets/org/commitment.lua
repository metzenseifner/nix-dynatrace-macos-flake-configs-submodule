return {
  s("COMMITMENT", fmt([[
  COMMITMENT <title>
  :PROPERTIES:
  :OPENED: [<date>]
  :TYPE: COMMITMENT
  :BY: <who>
  :END:
  <content>
  ]],
    {
      title = i(1),
      who = i(3),
      content = i(2),
      date = f(function(args, snip)
        return require('date_utils')
            .timestamp_orgmode()
      end)
    },
    { delimiters = "<>" })),
  s("COMMITMENT-gaps", fmt([[
   COMMITMENT Identify a set of gaps between where you are and where you are going and create action points that would close each gap. <title>
   :PROPERTIES:
   :OPENED: [<date>]
   :TYPE: Performance Enablement
   :BY: <who>
   :END:
    There are two kinds of gaps:
    1. gaps according to you (self-analysis gaps)
    2. gaps according to others (external gaps)
    While gaps are abstractions that explain /what/ you want to achieve, action points
    describe how you plan to close each gap.
    We can then convert gaps into commitments/goals on successfactors and applied actions into progress updates as comments to each goal on successfactors
    This will be valuable in your next Review Session, where you can make a case for your promotion.
    <content>
    ]],
    {
      title = i(1),
      who = i(3),
      content = i(2),
      date = f(function(args, snip)
        return require('date_utils')
            .timestamp_orgmode()
      end)
    },
    { delimiters = "<>" })),
}
