local design_txt = [[
* Design

Defines the purpose and responsibilities of this software project.

* Use Cases
# Way of defining the functional requirements
** Use Case 1 — A
*** Name
*** Description
*** Precondition
*** Trigger
*** Basic Flow
*** Alternative Flow
** Use Case 2 — B
** Use Case 3 — C

* Requirements
# Nonfunctional Restraints
** Security
# Any sensitive data?
** Capacity
# Any max or min data sizes in the data flow or storage?
** Compatibility
# Any min hardware requirements?
** Reliability and availability
# min allowed failures? accessibility hours for app? downtime?
** Maintainability and Manageability
# Should we fix bugs? Which ones?
# Should we keep up to date by tracking e.g. packages, hardware, OS
** Scalability
# max load app can handle normally. defined by early software decisions and infrastructure.
** Usability
# Quality of user experience like external help and docs? in-app help for coaching user? progress updates?
** Performance
# Min values for waiting? Responsiveness to user actions
** Environment
# Which operating systems? which environment variables? any dependencies on other software?

* Bounded Context
# Clearly define scope of this application functionality and be careful when extending to find the right abstraction to balance simplicity, functionality, and maintanability costs.

* Ubiquitous Language
# Define morphemes (words) clearly to distinguish them from subtle differences in other projects or align them with the larger group of people.
]]

return {
  s({ trig = "software_design_template" }, fmt(design_txt, {}, { delimiters = "[]" }))
}
