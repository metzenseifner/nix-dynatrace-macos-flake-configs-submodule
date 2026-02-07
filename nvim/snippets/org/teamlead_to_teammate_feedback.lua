local template = [=[
# Given their self-evaluation, you’re in a strong position: they’re very self-aware and already named most of the key themes. Your job is mainly to:
# 
# 1. **Reinforce and make concrete the strengths**
# 2. **Affirm and slightly sharpen the growth areas**
# 3. **Turn everything into 2–3 clear focus outcomes for the next period**
# 
# Here’s a structured way to approach it.
# 
# ---
# 
# ### 1. Frame the conversation
# 
# Set the stage as *developmental*, not evaluative:
# 
# - “My goal with this feedback is to recognize what you’ve achieved and align on how we can grow your impact next year.”
# - “You’ve already done a great job reflecting; I mostly want to add examples and help prioritize.”
# 
# This lowers defensiveness and respects that they’ve clearly thought about their performance.
# 
# ---
# 
# ### 2. Start with strengths (and be specific)
# 
# Use concrete examples and impact. Think in terms of **Situation – Behavior – Impact**.
# 
# You might say things like:
# 
# 1. **Fast onboarding and ramp-up**
# 
#    - “Joining in August and already being a key person for promotion-related work is clearly above expectations for someone at your tenure.”
#    - Add a specific moment:  
#      - “For example, when we were working on \<XYZ promotion change\>, you were able to contribute meaningfully despite still onboarding to the domain. That shortened our timeline and reduced the load on more tenured team members.”
# 
# 2. **Ownership of the promotion service**
# 
#    - “Your end-to-end ownership of the promotion service is one of the core pillars of how Team Care operates right now.”
#    - “Getting it to production, extending it with stages, and then backing it up with detailed runbooks is exactly the kind of ownership and reliability that we need around critical services.”
#    - Explicitly link to bigger impact: “Because of your runbooks, the shared on-call with Poseidon is far more sustainable and less dependent on a single person.”
# 
# 3. **Collaboration, leadership, and support for others**
# 
#    - “I want to underline your emerging leadership: you moved from taking on individual tasks to leading bigger promotion-related work items with others.”
#    - “Peers see you as a go-to person for Go expertise and for promotion service knowledge, and they also highlighted your calmness in stressful situations. That’s a huge asset for the team.”
#    - “Your support for others’ onboarding and your questions in stakeholder meetings show that you’re already operating with a broader, business-aware mindset.”
# 
# **Key message to deliver:**  
# “You ramped up quickly, took real ownership of a critical service, and you’re already showing leadership traits. That’s a strong trajectory for someone who joined in August.”
# 
# ---
# 
# ### 3. Align on growth areas (mostly confirm and refine)
# 
# They already named great development topics. Your role is to:
# 
# - Confirm they’re important
# - Add your perspective
# - Make them more concrete and observable
# 
# You can structure it around 3 themes:
# 
# #### A. Deepening domain & system understanding
# 
# Affirm:
# 
# - “I agree that deepening your understanding of our stakeholders, neighboring teams, and the overall system will amplify your impact.”
# 
# Make it concrete:
# 
# - “For the next period, I’d like you to:
#   - Proactively connect with X/Y stakeholder teams to understand their goals and constraints.
#   - Own creating or updating a high-level view of promotion-related services and dependencies.
#   - Take a leading role in identifying where we can strengthen automated acceptance and regression tests for promotion.”
# 
# Link to growth:
# 
# - “This is the bridge from ‘strong service owner’ to someone who shapes our roadmap and architecture.”
# 
# #### B. Focus and prioritization (managing ad-hoc work)
# 
# Normalize first:
# 
# - “It’s very natural that as the promotion expert you attract ad-hoc requests. That’s actually a sign of trust.”
# 
# Then gently sharpen:
# 
# - “Where I agree with the peer feedback: at times, reacting to these ad-hoc requests has hidden impacts on sprint commitments and predictability.”
# 
# Co-design a strategy:
# 
# - “I’d like us to define a clearer playbook together. For example:
#   - For unplanned work from external stakeholders, bring it to me or the team quickly so we can trade off explicitly.
#   - Use the board to flag unplanned items and what they displace.
#   - Practice saying: ‘I can do this, but that means X will slip. Is that acceptable?’”
# 
# Frame as a senior skill:
# 
# - “Being deliberate and transparent with trade-offs is a key senior-level behavior. You’re close to it already; we just need to make it more systematic.”
# 
# #### C. Distributing work & involving others earlier
# 
# Start with appreciation:
# 
# - “Your tendency to take on a lot yourself comes from a good place — ownership and wanting to unblock others.”
# 
# Then highlight the risk and opportunity:
# 
# - “But for the team, and for your own growth, we need to reduce the bus factor on promotion and create more chances for others to learn.”
# 
# Make it actionable:
# 
# - “This year, I’d like you to:
#   - Intentionally identify parts of promotion-related work that others can own end-to-end.
#   - Involve others early: do a short kickoff, share context, then let them implement while you support.
#   - Use pairing and code reviews as teaching opportunities rather than just fixing things yourself.”
# 
# Connect to leadership:
# 
# - “This is how you move from ‘key contributor’ to ‘multiplier’ — someone who raises the whole team’s capability.”
# 
# #### D. Planning and breaking down larger topics
# 
# Validate their self-observation:
# 
# - “Your point about jumping into implementation is accurate and not unusual for someone strong technically.”
# 
# Reframe as growth towards broader impact:
# 
# - “To lead bigger topics, the planning phase becomes as important as the coding phase.”
# 
# Make it concrete:
# 
# - “For larger work items, I’d like you to:
#   - First write a short plan or design (even half a page): goals, constraints, risks, rough breakdown.
#   - Share it with me and the team before you dive into code.
#   - Use that plan to coordinate who does what and to set expectations with stakeholders.”
# 
# You can give a simple rule:
# 
# - “If it’s more than a couple of days of work, it deserves at least a lightweight written plan and explicit breakdown.”
# 
# ---
# 
# ### 4. Acknowledge challenges without over-focusing on them
# 
# They described their challenges thoughtfully. You can:
# f
# - Validate: “Onboarding into a broad, evolving domain *and* owning a complex service like promotion is genuinely hard. The deployment ring changes mid-onboarding were a big extra twist.”
# - Recognize response: “Given that, your ability to build a working mental model, deliver production-ready changes, and support stakeholders is even more impressive.”
# 
# This keeps the narrative as: **hard context → strong response → now we refine and scale.**
# 
# ---
# 
# ### 5. Close with 2–3 concrete goals
# 
# To avoid a “laundry list,” leave the conversation with a small set of clear outcomes. For example:
# 
# 1. **System & testing**
#    - “Lead an initiative to map promotion-related services and propose at least one meaningful improvement in automated acceptance/regression testing.”
# 
# 2. **Delegation & collaboration**
#    - “For major promotion features, ensure at least one other teammate owns a significant part end-to-end, with you in a mentoring/consulting role.”
# 
# 3. **Planning & prioritization**
#    - “For every larger topic:
#      - Share a written plan before implementation.
#      - Make trade-offs for ad-hoc requests explicit in the board and in communication with me/stakeholders.”
# 
# You can ask them to propose the final wording to increase ownership.
# 
# ---
# 
# ### 6. Example “script” you could adapt
# 
# You could structure your feedback like this:
# 
# > “What stood out to me this year is how quickly you ramped up and how strongly you took ownership of the promotion service. Getting it into production, extending it with stages, and making it operable through runbooks has had a huge impact on how Team Care and Poseidon handle releases.  
# >  
# > I also see you increasingly as a leader in promotion topics: you’re calm under pressure, peers seek out your Go and domain expertise, and you support others’ onboarding. For someone who joined in August, that’s an excellent trajectory.  
# >  
# > In terms of growth areas, I largely agree with what you wrote. I’d like us to focus on three things:
# > - Deepening your understanding of the broader domain and stakeholders, so you can influence our roadmap and architecture more.
# > - Protecting focus and distributing promotion-related work more, so you’re not the bottleneck and others can grow in this area.
# > - Spending more time upfront on planning and breaking down large topics before coding, to make collaboration smoother and expectations clearer.  
# >  
# > None of these are about fixing weaknesses; they’re about scaling the impact you already have. Let’s turn these into 2–3 concrete goals for the next period and check in on them regularly.”
# 
# ---
# 


# They already named great development topics. Your role is to:
# 
#     Confirm they’re important
#     Add your perspective
#     Make them more concrete and observable
# 
# You can structure it around 3 themes:

My goal with this feedback is to recognize what you’ve achieved and align on
how we can grow your impact next year.
You’ve already done a great job reflecting; I mostly want to add examples,
tips, and help prioritize.


# Make a strong positive statement
What stood out to me this year is how

# growth area alignment
In terms of growth areas, I largely agree with what you wrote. I’d suggest focus on three things:

# team captain role-specific remarks since dev manager has the rest
As a team captain, I have a couple closing remarks:
]=]

return {
  s("feedback-for-teammate", fmt(template, {}, {delimiters="[]"}))
}
