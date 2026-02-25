local ai_changes = [=[
* End of Year Review FY2026
** What AI Changed and Why
Here’s what I changed and *why* — so you can reuse the same techniques next time.

---

### 1. Structure: turn a long text into a clear narrative

**What I did**

- Kept your overall outline but:
- Added a short framing intro: *“You have faced… I’d like to share…”*  
  - Turned each theme into a clear section with a heading:  
    - Managing Stress  
    - Navigating Difficult Senior‑Level Relationships  
    - Stepping Up in Mentorship  
    - Supporting Outside the Team  
    - Planning Engagement  
    - Note from Your Team Captain
  - Used transitions between sections so it reads like a story, not disconnected bullets.

**Why it’s better**

- The recipient can quickly see “what this is about” and scan by topic.
- It reads like a coherent growth journey, which reinforces the promotion narrative.

---

### 2. Feedback craft: behavior → impact → growth

**What I did**

- Consistently followed a pattern close to SBI:
  - **Situation** – “In the first half of the year…”
  - **Behavior** – “You set boundaries… you de‑escalated before reacting…”
  - **Impact** – “I can now rely on you for a calm demeanor… you built bidirectional trust…”
- For each area, I ended on **growth / outcome**, not on the problem:
  - Stress: from “recurring issue” → “now a calm, helpful demeanor I can rely on.”
  - Relationship with Matthäus: from “conflict” → “bidirectional trust.”
  - Mentorship with Matthieu: from “hard to prioritize / connect” → “clearer mentoring style and what you need to succeed.”

**Why it’s better**

- Makes the feedback feel like *evidence of readiness* for Senior II, not a list of issues.
- Connects concrete behaviors to impact, which is what promotion reviewers look for.

---

### 3. Tone & psychological safety (especially around other people)

This was the most sensitive part.

**What I changed**

Original phrases like:

- “You were victim of Matthäus being controlling”
- “blasts at refinements”

Became more neutral and professional:

- “There were moments where discussions were not on eye level and where communication from his side could feel overly controlling or intense (e.g., some blasts in refinements).”
- Focus shifted from “Matthäus is controlling” → “you navigated a difficult dynamic in a mature way.”

I also:

- Removed “victim” language and blamey wording.
- Used “I observed…” / “my impression is…” to anchor statements as your perspective.
- Emphasized their *agency* in improving the relationship: de‑escalating, setting expectations, building trust.

**Why it’s better**

- Keeps the feedback document safe to share and not accusatory towards another senior.
- Highlights the person’s **relational skill** rather than another person’s flaws.
- Matches a senior‑level tone: calm, fair, balanced.

---

### 4. Language & readability

**What I did**

- Fixed grammar and typos:
  - “challenge” → “challenges”, “your with a sense” → “you with a sense”, “an big impact” → “a big impact”, “agressively” → “aggressively”, etc.
- Removed repetitions and tightened long sentences into clearer ones.
- Clarified ambiguous references (“this”, “it”) so it’s obvious what you mean.
- Smoothed small wording issues (“Note from your Team Captain” stays, but the paragraph flows more).

**Why it’s better**

- Feels more polished and “official,” which matters in promotion‑relevant feedback.
- the recipient can read it quickly and understand without re‑parsing sentences.

---

### 5. Emphasis: make the promotion case explicit

**What I did**

- Reiterated the promotion context at the beginning and end:
  - Opening: “especially your promotion to Senior Software Engineer II…”
  - Closing: “based on my assessment, you deserve a promotion this year…”
- Throughout the text, I highlighted **senior behaviors**:
  - Role‑modeling under stress
  - Navigating complex senior relationships
  - Mentoring under non‑ideal conditions
  - Influencing outside the team (stakeholders, transparency)
  - Planning and abstraction improvements
- The closing paragraph is clearly framed as:
  - “Your growth plan was outstanding”
  - “You took goals seriously and worked strategically”
  - “I recommended you for promotion”

**Why it’s better**

- Anyone reading the feedback (Dev Manager, calibration group) immediately sees:  
  *“This is a promotion recommendation, backed by concrete evidence.”*
- The recipient gets both recognition *and* a confidence boost.

---

### 6. Emotional framing: honest but motivating

**What I did**

- Kept all the hard topics you raised (stress, conflict, tough mentoring situation) but:
  - Framed them as **growth arcs**, not as “problems you had.”
  - Used appreciative language: “strong example of senior‑level interpersonal growth,” “stepped up your game,” “role‑model behavior.”
- Ended on a high:
  - Mutual trust
  - Appreciation for involvement
  - Clear statement of your support for promotion
  - Encouragement regardless of formal timing

**Why it’s better**

- Delivers tough truths without leaving a “down” feeling.
- The person finishes reading feeling *proud* and *motivated*, not defensive.
]=]

local structure_tips = [[

* End of Year Review FY2026

My goal with this feedback is to recognize what you’ve achieved and align on
how we can grow your impact next year. You’ve already done a great job
reflecting; I mostly want to add examples and help prioritize.

** Highlights

** Growth Areas

** Challenges

** Statement from your Team Captain

** Structural Feedback Tips
# Set the stage as *developmental*, not evaluative:
#  
# - “My goal with this feedback is to recognize what you’ve achieved and align
# on how we can grow your impact next year.”
# - “You’ve already done a great job reflecting; I mostly want to add examples
# and help prioritize.”
#  
# ### 2. Start with strengths (and be specific)
# 
# Make a strong positive statement
# What stood out to me this year is ...
# Use concrete examples and impact. Think in terms of **Situation – Behavior – Impact**.
# End with a key message to deliver in terms of impact.
# 
# ### 3. Align on growth areas (mostly confirm and refine)
# 
# They already named great development topics. Your role is to:
# 
# - Confirm they’re important
# - Add your perspective
# - Make them more concrete and observable
# 
#  Take liberty to structure that around themes.
# Link to growth, normalize, and gently sharpen (where I agree, at times, blah blah)
# Consider a cooperative appraoch: I'd like to define a playbook together.
# 
# Frame arguments according to role or desired role seniority.
# - Highlight risks and opporunities
# - Make feedback actionable.
# 
# ### 4. Acknowledge challenges without over-focusing on them
# 
# They described their challenges thoughtfully ideally. You can
# - Validate
# - Recognize response
# This keeps the narrative as: **hard context → strong response → now we refine
# and scale.**
# 
# ### 5. Close with 2–3 concrete goals and statement from Team Captain
# Focusing on strengths and being aware of weaknesses:
# You can also ask them to propose the final wording to increase ownership.
# > In terms of growth areas, I largely agree with what you wrote. I’d like us to focus on three things:
# > None of these are about fixing weaknesses; they’re about scaling the impact
# you already have. Let’s turn these into 2–3 concrete goals for the next period
# and check in on them regularly.”
]]

return {
  s("end-of-year-review-ai-changes", fmt(ai_changes, {}, {})),
  s("end-of-year-review-structure", fmt(structure_tips, {}, {}))
}
