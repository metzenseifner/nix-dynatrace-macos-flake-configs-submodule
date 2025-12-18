local template = [[
* Review of <name>

In this review of <name>, I will prefix points with GOOD, OK, or MISSED OPP standing
  for impressive, decent, and a missed opportunity to shine, respectively.

* Grade assessment:

<grade>

* Statement:

<name> <statement>

* Other teams:

<other>

* Personality:

- <personality>

* Agile Practice

- <agile>

* Showcase 1: <showcase>

* Architectural Understanding

- <architecture>

* Testing

- <testing>

* Programming Skills

- <programming>

* Coding Challenge

]]

local competences = [[
* Automation Engineering
** Knows the Dynatrace toolchain and automation capabilities.
** Observes the efficiency and potential issues.
** Knows various alternatives in tooling and practices. 
** Can advise new automation processes or tooling’s fitting into the existing landscape.
** Is able to capture automation requirements and guide the teams to the right targets.
** Ensures consistency of the tooling and processes in all responsible areas.
** Can document and identify gaps in automation processes.
** Understands the benefits of a central automation platform.
** E2E thinking – from the first requirement to a deployed artefact.
* Architecture
** Sees and understands the big picture regarding architecture.
** Thinks abstract about how a feature fits into existing architecture.
** Keeps dependencies in mind. (e.g. refactoring, coupling)
** Knows how to structure components, keeping it maintainable and extensible in the future.
** Consider possible improvements in future. (not cut out some path)
** Is aware of security patterns: possible attack vectors, ...
** Can drive technology decisions (language, third-party libraries/systems...) and implement system architecture.
** Understands how to write, build (componentization, modules ...), and run (containerized, clustered, interaction of microservices...) software.
** Can balance effort, do-ability, and costs.
** Can design APIs (performance, usability, ...)
** Avoids overengineering and applies common sense.
** Practices an iterative approach -plans and builds step by step.
** Explains the architecture in a coherent way.
** Makes unbiased and context-based decisions. (e.g monolith vs. microservice) 
** Reuses existing components and systems, avoids the not invented here syndrome.
** Makes systematic and evaluation-based decisions.
** Avoids stepping on every latest development and hype-driven development.
** Avoids premature optimization. (micro-optimizations and small efficiencies, but covers the critical 3%)
* Coding & Algorithms
** Understands idioms (e.g. asynchrony, reactive), concepts, possibilities, and limitations of the language one codes
** Is able to review code and give constructive feedback
** Adjusts coding approach to requirements (performance,
** readability, memory usage...)
** Applies refactoring: if something gets too big and bulky, builds from scratch
** Is aware of Sonar rules and follows them
** Understands parallel runtime behavior (synchronization and locking)
** Knows standard frameworks and when to apply them
** Is able to write code which is:
   1. Efficient with regards to performance (e.g. understanding collections, data structures, data types) and maintenance
   2. Readable and self-explanatory, meaning one, one´s future self, and others can easily read it (eg uses comments and documents code on the Why and How, less is more) 
   3. Clean, unambiguous (cf clean code), and testable, especially single methods
   4. Secure and safe (cf multithreading, concurrency, chose the 
   right visibility (private members, only expose behavior, not state), sanitizes input from untrusted sources, sticks to code safety principles -Code Level Security: finals, read-only, immutability)
   5. Easy to debug and to fix when problems are identified
   6. Extendable and future proof
]]

return {
  s("review-2nd-round", fmt(template, {
    name = d(1, function(args, parent)
      local insertSnippetNodeFromSelectionElseInsertNode = function(args, parent)
        if (#parent.snippet.env.LS_SELECT_RAW > 0) then
          return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
        else -- If LS_SELECT_RAW is empty, return a blank insert node
          return sn(nil, i(1))
        end
      end
      return insertSnippetNodeFromSelectionElseInsertNode(args, parent)
    end),
    grade = i(2),
    statement = i(3),
    other = i(4),
    personality = i(5),
    agile = i(6),
    architecture = i(7),
    testing = i(8),
    programming = i(9),
    showcase = i(10),
  }, { delimiters = "<>", repeat_duplicates = true })),
  s("competences", fmt(competences, {}, {}))
}
