return {
  s("train", fmt([[
    - [ ] Use business reason for claim header and use it across all expenditures from Dev Manager, read https://dynatrace.sharepoint.com/sites/DERB/SitePages/Prefixes-%26-Exclusions.aspx#claim-prefixes
    - [ ] Hotel: Hotel itemization required: https://dynatrace.sharepoint.com/sites/EmployeeUniverse/SitePages/Concur-Claim.aspx#how-to-add-a-hotel-receipt
      - [ ] Travel Allowance https://dynatrace.sharepoint.com/sites/EmployeeUniverse/SitePages/Concur-Claim.aspx#how-to-add-daily-allowance-(for-austria%2C-poland-czech-republic-only!)
        - [ ] Itineraries: total travel time from home or from the hotel.
        - [ ] Expenses & Adjustments: means checking whether breakfast, lunch, dinner included for given days.
      - [ ] Tax Receipt for receipt type.
      - [ ] If the room rates are different each night choose "Not the Same"
      - [ ] Room Rate (per night) e.g. if 2 nights for total 224 (without sep breakfast line), then put 112 per night.
      - [ ] Room Tax - Update: you don't need to split the tax, it can be included into the room rate
      - [ ] Breakfast - Update: if the breakfast is mentioned as a separate
      line on your receipt you need to add it as an separate itemisation: click
      Add Itemisation, Expense Type Hotel Breakfast and add the amount of
      breakfast for each line.
    - [ ] Train
      - [ ] In comments, add directions and return e.g. LandeckZams-Vienna; return Vienna-LandeckZams.
      - [ ] Tax Receipt for receipt type.
  ]], {}, {})),




}
