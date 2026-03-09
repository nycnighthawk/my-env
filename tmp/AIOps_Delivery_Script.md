# AIOps Delivery Script — Virtual (MS Teams)
## "Signal Over Noise: What AIOps Really Is, Where We Are, and Where We're Taking You"

**Presenter:** [Your Name]
**Delivery format:** Virtual, MS Teams
**Audience:** Engineers · Developers · Technical Managers · Non-Technical Managers · Executives · Business Colleagues
**Total Target Time:** 46–50 minutes | Q&A: 10 minutes
**Tone:** Honest · Self-aware · Upbeat · Forward-looking

---

## 📋 PRE-SESSION CHECKLIST

**Technical (15 minutes before)**
- [ ] Camera on, eye level or slightly above. Prop your laptop if needed — the chin-down angle unintentionally conveys either exhaustion or mild menace.
- [ ] Light in *front* of you. Backlit = witness protection. Front-lit = credible professional.
- [ ] Headset or external mic. Built-in laptop mics are fine for quick calls. They are not fine for 50-minute presentations where you need people to actually stay with you.
- [ ] Close every app that generates notifications — Slack, email, Teams popups, all of it. If a P1 alert slides across your screen mid-presentation, you will have inadvertently made the best possible case for this talk while also having the worst possible day.
- [ ] Confirm presenter view is private, slides advance correctly.

**Audience strategy — read this before you present**

This room is genuinely mixed. Engineers who are in the weeds of incident response. Managers trying to explain to their stakeholders why resolution took three hours. Executives watching SLA dashboards and business impact reports. Business colleagues who don't care how Elastic works but care enormously that their applications are down and their customers are waiting.

They experience the same problem from completely different angles. Your job is to speak to all of them in the same talk without losing any of them.

The way you do that:
- **Open with the business experience of the problem** — not the technical one. Everyone in the room has either felt it or had to explain it.
- **Translate between languages throughout** — when you describe a technical gap, immediately follow with what that means operationally and what it costs the business.
- **Let engineers feel seen without excluding everyone else** — the technical credibility matters, but it can't be the whole register.
- **Stay upbeat** — this is a talk about what's broken, delivered by the person accountable for fixing it. Own it with energy, not apology.

The core problem is not false alerts. The core problem is **MTTD and MTTR** — how long it takes to know something is wrong, and how long it takes to fix it. Everything in this talk connects back to that.

---

---

## SLIDE 1 — Title Slide: "Signal Over Noise"
**⏱️ 3–4 minutes**

---

**[Unmute. Camera on. One breath. No "Can everyone see my screen?" No "Good morning, everyone." Begin like you mean it.]**

I want to describe a scenario that I think will be familiar to most people on this call — just from different seats.

**[Pause. Let the room settle.]**

Something goes wrong with an application. Maybe a monitoring tool opens an incident. Maybe — and this one stings a little — a user calls in to report it before the tool does. Either way, an incident is open. The on-call engineer is engaged. The clock is running.

And then the real work begins.

Not the fix — the *figuring out*. What is actually happening? Is it this service, or something upstream? Is it the application, the infrastructure, the database, the network? The engineer starts pulling logs. Checks dashboards — multiple dashboards, across multiple tools, that weren't built to talk to each other. Starts correlating signals manually, in their head, in real time, while the application is down and the business is waiting.

That investigation — that period between "something is wrong" and "we know exactly what it is and how to fix it" — that is where the time goes.

**[Pause. Let it sit for a beat. Then continue with energy, not heaviness.]**

And the recovery — once the root cause is identified — that's its own story. Runbook? Maybe. Somewhere. If it was written down. If it was updated the last time this happened. If the right person is on call who's seen this before.

This is the problem. Not a bad tool. Not a bad team. A system that makes the hard parts harder than they need to be.

This talk is about what we're doing to change that. For engineers, for managers, for the business — I want everyone on this call to leave with a clear picture of where we are, where we're going, and what we need from you to get there.

Fifty minutes. Questions at the end. Let's go.

---

## SLIDE 2 — Agenda
**⏱️ 1 minute**

---

Here's the shape of the next 50 minutes.

We start by defining what AIOps actually means — because the term has been stretched far enough that it no longer means the same thing to everyone. Then we get honest about where we are today. Then I show you what we're building: the standards framework, the operating model, the north star. And we close with the roadmap and specific asks for each group on this call.

Let's get into it.

---

## SLIDE 3 — What Is AIOps?
**⏱️ 5–6 minutes**

---

**[Measured pace. Let this land as a reframe, not a vocabulary lesson.]**

Let me start with the definition, because I think a shared one matters before we go any further.

"AIOps" is one of those terms that has been stretched across enough vendor marketing, conference keynotes, and org charts that it now means slightly different things to almost everyone who uses it. And if we're going to spend 50 minutes talking about where we are and where we're going, I'd like us to be working from the same definition.

**[Three cards on screen. Walk them clearly — some people in this room will know Elastic and Ansible, others won't. Speak to both without condescending to either.]**

**SEE EVERYTHING** — That's Elastic. Logs, metrics, traces, application performance, synthetics. The ability to see what is happening across your entire technology stack, in one place, in real time, with context. For the business side of this call: this is the difference between "we know something is wrong" and "we know exactly what is wrong, where, and why."

**ACT ON EVERYTHING** — That's Ansible AAP. Governed, auditable automation. The ability to respond to what we see — consistently, repeatably, with a full audit trail — without requiring a human to manually execute every step of a recovery process every single time.

**GET SMARTER** — That's the AI layer. Anomaly detection. Automated root cause analysis. Pattern recognition across more signals than any team can process manually. The future state we're building toward.

The through-line at the bottom of this slide: *Observability feeds automation. Automation reduces noise. Less noise means better signals.*

Here's what that means in practice: right now, when an incident opens, an engineer has to manually piece together what happened from multiple sources. That takes time. MTTD — mean time to detect the actual root cause — is longer than it should be. And because recovery depends on what was found during that investigation, MTTR — mean time to restore service — follows right behind it.

An AIOps operating model is what shortens both of those numbers. Not by working harder. By working with better information, faster.

Let me tell you how we got here.

---

## SLIDE 4 — How We Got Here
**⏱️ 3–4 minutes**

---

**[The timeline shows teams first, then the re-org. Walk it in order — the sequence matters for the story.]**

Two teams existed before the AIOps organization. The Automation Team, running Ansible AAP. The Observability Team, running Elastic. Both were doing real work. Both had real capability.

In October 2025, a re-org brought both teams together under a single AIOps mandate.

**[Pause. This is the self-deprecating moment — warm, not heavy.]**

Now — I want to be honest about what that kind of transition actually looks like from the inside, because I think honesty here is more useful than a polished story about seamless integration.

Think about two experienced chefs. Both talented. Both have spent years developing their craft in their own kitchen. Their systems work. Their processes work. Their team knows exactly how things are done.

And then one day: shared kitchen. Same menu. Go.

What you get initially — and I say this as someone currently living this transition — is two groups of genuinely capable people who are professionally and collegially figuring out where one team's model ends and the other's begins. Who has the final call on the standards. How the tools connect. What "done" means when both platforms are involved.

That is not dysfunction. That is a real transition, and real transitions take intention to navigate well.

We have the intention. We have the teams. We have the platforms. And today I'm showing you what we're building with them.

---

## SLIDE 5 — Where We Actually Are — Honest Edition
**⏱️ 6–7 minutes**

---

I want you to notice the subtitle on this slide.

**[Pause.]**

"Honest Edition." I put that there deliberately. I've sat through enough team update presentations — and delivered enough of them — to know the default mode: lead with wins, soften the gaps, show a green roadmap, and move on. It's comfortable. It is also not very useful when the people in the room are the ones dealing with the gaps in real time.

So you're getting the honest version. I'll ask you to receive it in the spirit it's intended — not as a confession, but as a diagnosis. You can't build a real solution on a vague problem statement.

**[Elastic card — left side.]**

Elastic Observability. We have a capable platform. The infrastructure is solid, the data is there. But the implementation is inconsistent. Different teams have instrumented their applications differently — some thoroughly, some minimally, some not at all. Dashboards vary so much between teams that there's no shared operational language when an incident spans multiple systems. And critically: when something goes wrong, the context that would make diagnosis fast — correlated signals, historical baselines, clear ownership — often isn't there. Engineers are piecing together the picture manually, from multiple places, under pressure.

**[Ansible card — right side.]**

Ansible AAP. Genuinely powerful automation engine. But we've been running it without the governance that makes automation trustworthy at scale. No mandatory peer review before playbooks go to production. Changes have reached production without full impact assessment. The result is that automation — which should be one of our greatest tools for *reducing* recovery time — has instead, in some cases, contributed to incidents that required their own recovery.

**[This is the business translation moment. Slow down here — this is where you connect the technical reality to the room that isn't technical.]**

Here's what this means in language that applies to everyone on this call.

When an application goes down, the business expects one thing above all others: fast, accurate resolution. Not heroics. Not a war room at 11 PM where three engineers are manually correlating logs from four different sources trying to figure out what happened. Fast, accurate resolution — grounded in data that was already in place before the incident opened.

We are not reliably delivering that today. MTTD is longer than it should be because the observability foundation is inconsistent. MTTR is longer than it should be because recovery depends too heavily on individual knowledge and manual processes instead of governed, reliable automation.

**[Bottom banner.]**

The expectation is consistency and agility. Unplanned disruptions erode that trust. And the operational gaps I just described are why those disruptions keep happening.

That's the honest edition. Now let's talk about why.

---

## SLIDE 6 — Why This Happened
**⏱️ 3–4 minutes**

---

Three things contributed to where we are. I'll name them directly.

**No shared standards.** Each team built their own conventions. Both sets of conventions were reasonable. Neither was wrong. But "two reasonable but separate approaches" compounds quickly — across teams, across time, across incidents — into a situation where nobody knows what to expect from the other platform's outputs, and interoperability between the two is mostly manual.

**No review governance.** Work shipped without cross-team review or structured quality gates. Fast, but without the discipline that makes fast sustainable over time.

**Platform potential unrealized.** Two excellent tools, side by side, without a shared architecture or integration model. The ingredients were there. The recipe wasn't.

**[Self-deprecating — own it, then pivot immediately forward.]**

I want to be transparent about something: I can describe these three things crisply right now partly because I was not the one making the calls when most of this foundation was laid. The people who built what we have were solving real problems at real speed under real constraints. That context matters.

What I don't get to do is use that as a reason to leave things as they are. The gaps are real. They're affecting engineers during incident response, managers explaining timelines to their stakeholders, and the business waiting for applications to come back online. Closing those gaps is the job.

The quote at the bottom of this slide is the pivot: *Fast growth plus good people plus no architecture discipline equals a patchwork. We're turning it into a platform.*

Everything from this point forward is the answer to everything before it.

---

## SLIDE 7 — The Tools Are Excellent
**⏱️ 4–5 minutes**

---

Before I show you how we're fixing this, I need to say something clearly — because I don't want the last two slides to leave the wrong impression.

**[Pause.]**

The platforms are not the problem.

Elastic is a world-class observability platform. Enterprises pay serious money for what we have deployed. The engineers who work in it every day know its capability. It is not the issue.

Ansible Automation Platform is the enterprise standard for IT automation for a reason. The engineers who run it know what it can do. Also not the issue.

Both platforms on screen carry the same status: *Platform: check. Implementation: in progress.*

**[The humor moment. Let it build.]**

Here's the analogy I keep coming back to: we have a Ferrari and a Porsche in the garage. Both in excellent condition. Both capable of things that would genuinely impress you.

We have been using them to drive to the corner store. In second gear.

**[Hold the pause. For the engineers it's a technical self-own. For the business side it's an accessibility metaphor. It works for both. Let the room sit with it.]**

That is a maturity gap, not a platform problem. The tools are ready. What we're building is the operational discipline, the standards framework, and the integration layer that lets them perform the way they were designed to.

That is a completely solvable problem. Here's what solving it looks like.

---

## SLIDE 8 — The AIOps Flywheel
**⏱️ 5–6 minutes**

---

**[This slide is the operating model. Narrate it thoroughly — half the room may not be looking directly at their screen. Speak the picture.]**

On screen: a circular flow diagram, five nodes. This is the model we're building toward. Let me walk you through it — and as I do, I want you to map it against that opening scenario I described. The incident. The scramble. The investigation. The recovery.

**OBSERVE** — Elastic sees everything happening in the environment. Logs, metrics, traces, correlated and in context. For the business side: this is the foundation of every other capability. You cannot detect fast if you cannot see clearly.

**DETECT** — The system interprets what it sees. Anomalies surface — not because a user called in, not because an on-call engineer happened to be watching the right dashboard, but because the system recognized a pattern that warranted attention. For engineers: this is the difference between MTTD measured in minutes versus hours.

**RESPOND** — A defined response pattern triggers Ansible. Pre-approved automation runs — consistently, repeatably, with a full audit trail. The recovery starts before a human has to manually diagnose and execute every step. For managers and the business: this is where MTTR starts to fall.

**LEARN** — Did the response work? Was the detection accurate? That feedback improves the system. Thresholds sharpen. Playbooks get refined. The next incident of the same type resolves faster.

**IMPROVE** — The loop tightens. Detection gets faster. Recovery gets more reliable. The dependency on individual knowledge and manual heroics during incidents decreases.

**[Pause. This is the honest moment that earns credibility with engineers and grounds the vision for everyone else.]**

Here is where we are today: we spin this loop. We spin it manually, inconsistently, and at the speed and accuracy of whoever is engaged at the moment an incident opens. When the right engineer is on call and the right context exists, it works reasonably well. When neither of those conditions is met — and they often aren't — MTTD is long and MTTR follows.

What we're building is a version of this loop that doesn't depend on the right person being available and having the right context in their head.

*Today we spin this manually. We're building the engine.*

---

## SLIDE 9 — The Standards Framework
**⏱️ 5–6 minutes**

---

This is the part of the presentation where I acknowledge that "standards framework" is not a phrase that has ever caused anyone's pulse to quicken.

**[Slight self-aware smile in your voice.]**

I know. I have written standards documents that were thoroughly correct and almost completely unreadable. I am working on that. What I am not apologizing for is the substance, because here is the alternative:

An incident opens. The engineer pulls up the dashboard for the affected service — assuming the service has a dashboard, which not all of them do. They look for the runbook — assuming one was written, which not all of them have. They look for historical context — assuming the alerts are set up consistently enough to provide it. And they do all of this manually, under pressure, while the application is down and the clock is running.

That is what the absence of standards looks like in practice. Not a boring document. A longer MTTD and a longer MTTR.

**[Three columns on screen. Walk each one at a pace that serves both technical and non-technical listeners.]**

**Observability Standards.** Every production application meets a defined instrumentation baseline before it goes live. Every alert has a runbook, an owner, and a severity level that actually means something. Dashboards have a consistent structure so an engineer supporting an unfamiliar service knows where to look. New applications onboard into Elastic through a clear, repeatable process — not through whoever has the most context that week.

For the business side: this means that when something goes wrong, the information needed to diagnose and resolve it is already in place. Detection is faster because the signals are consistent and complete.

**Automation Standards.** Every playbook that runs in production has been reviewed. Changes go through a defined impact assessment before they reach production. There is a reusable library of automation components so we're not solving the same recovery problem in fourteen slightly different ways. The change trail is clean before something goes wrong, not reconstructed afterward.

For the business side: this means automation accelerates recovery instead of occasionally contributing to the problem.

**AIOps Integration Standards.** Observability signals and automation responses speak the same language. A detection event in Elastic can trigger a response in Ansible directly, without a human in the middle. The feedback loop is closed so the system learns from every incident.

For the business side: this is how MTTR falls — not through faster engineers, but through a system that doesn't require an engineer to be in the middle of every recovery step.

Standards v1.0 is a Q1 target. Published, enforced, office hours available. A standard you can opt out of is a suggestion, and we have enough of those.

---

## SLIDE 10 — What We're Building Toward
**⏱️ 5–6 minutes**

---

**[This is the peak of the talk. Everything before this was the diagnosis. This is what recovery looks like. Drop your pace. Lower your volume slightly. Tell them what you're about to do — then do it slowly.]**

I want to walk you through a scenario. Listen to this.

**[Read with deliberate pacing. Full pause at each paragraph break. Don't rush.]**

A new service gets deployed. It is instrumented on day one — not because someone filed a ticket and waited, but because the onboarding process is standard and self-serve. Visibility is live before the first real user.

Two weeks later, Elastic detects an anomaly. Not because a user called in to report a problem. Not because an on-call engineer happened to notice something in a dashboard. Before either of those things happened — the system detected it. The alert has full context: which service, what component, what the historical baseline looks like, what changed recently. No manual correlation needed. The engineer — if one is engaged at all — knows exactly what they're looking at from the moment they open the incident.

Because the observability standards are in place, the alert has a runbook attached. Because the automation standards are in place, that runbook is a pre-approved Ansible playbook. Because the integration standards are in place, Elastic triggers it directly.

The playbook runs. The application recovers.

The user never noticed anything was wrong.

**[Five full seconds of silence. On a Teams call this will feel long. It is correct. Hold it. Let every person in the room map that scenario to their own experience.]**

That is not a pitch. That is not a future roadmap item we're hoping for. We have Elastic. We have Ansible. Both platforms are live in our environment today.

What stands between where we are and what I just described is not technology. It is the standards layer that connects them, the governance that makes the automation trustworthy, and the integration patterns that close the loop.

**[Address each group — this is the only moment in the talk where you speak to each audience explicitly. Slow, deliberate, direct.]**

For the engineers on this call: this is the version of incident response where you have complete context from minute one, and where defined incident types resolve without requiring you to manually execute every step of a recovery you've done before.

For managers and technical leadership: this is consistent, measurable, predictable MTTD and MTTR — not dependent on who is on call that day.

For the business side and executives: this is the application your users don't know went down. This is the SLA you didn't breach. This is the incident that didn't make it onto the business impact report.

The tools are in the garage. We are building the road.

---

## SLIDE 11 — The Roadmap: Three Horizons
**⏱️ 5–6 minutes**

---

Everything I just described is achievable. Here is the sequence.

Three columns on screen: NOW, NEXT, and LATER.

**NOW — Q1 and Q2 2026. Stabilize.**

Already underway. Standards Version 1.0 for both platforms — published, with office hours. An Elastic alert audit: every alert in production evaluated against the new standards — does it have a runbook, an owner, a severity level that means something? Mandatory peer review for every AAP playbook before production. Top ten critical applications fully onboarded into Elastic. Principal engineer office hours, open to anyone on this call.

The objective of Stabilize is one thing: consistent, reliable foundation. You cannot build trustworthy automation on top of inconsistent observability. You cannot close the loop if the signals feeding it are incomplete. Stabilize fixes the foundation.

**NEXT — Q3 and Q4 2026. Standardize.**

Self-serve onboarding — getting a service into Elastic should not require filing a ticket to the AIOps team. A library of 20-plus reusable playbook components so recovery patterns are shared and consistent, not rebuilt individually for each team. The first observability-to-automation integration patterns running end-to-end. And an executive KPI dashboard showing MTTD, MTTR, and incidents prevented — the numbers that reflect whether the work is actually working.

**LATER — 2027 and beyond. Optimize.**

The AI layer. ML-assisted anomaly detection. Automated root cause analysis — the system not just detecting that something is wrong but telling you what and why. Self-healing patterns for defined incident types. The flywheel running close to autonomously.

**[This sequencing point is important — deliver it with conviction, not apology.]**

I want to be explicit: we do not skip Stabilize to get to Optimize. I know Optimize is the part that sounds exciting. But ML-assisted anomaly detection built on inconsistent observability data produces confident-sounding wrong answers. Automated root cause analysis built on unreviewed automation produces fast, authoritative mistakes.

The foundation is not the boring part. The foundation is the part that determines whether everything built on top of it actually works.

Stabilize. Then Standardize. Then Optimize. In that order.

---

## SLIDE 12 — Our Ask
**⏱️ 4–5 minutes**

---

**[This is the moment to name each group specifically. On a virtual call with cameras off, direct address is one of the few tools you have to bring people back into the room. Use it. Speak to each group as if you can see them.]**

Every person on this call has a part in what I just described. I want to be specific about what I'm asking.

**Application developers** — we're going to come to you with an Elastic onboarding request. It will land in a backlog that is already overcommitted. I'm not going to pretend otherwise. But instrumentation is not optional infrastructure — it is what makes fast detection possible. Without it, the scenario I described on the North Star slide doesn't happen. Please prioritize it when we come to you. We will make the process clear and the ask as small as we can.

**Engineering managers** — give us 30 minutes on your services. Thirty minutes for us to walk through how your applications appear in Elastic today, what we're seeing, and what we'd recommend. Come ready to be direct with us about what your teams are experiencing during incidents. We will come with specific findings and specific next steps. Reach out to **[contact name]** after this session to schedule it.

**Technical leadership** — back the standards with organizational authority. I'll be direct about this: if the peer review requirement for Ansible playbooks is optional in practice, it will be treated as optional. Standards require enforcement to become culture. Without organizational backing, I will be standing here in 18 months giving a very similar presentation, and I would genuinely prefer not to do that.

**Senior executives and business colleagues** — here is my specific ask. Measure us on MTTD, MTTR, and incidents that didn't affect users because they were detected and resolved before impact. Not ticket counts, not platform uptime as a vanity number — outcomes. If the work is succeeding, you will see it in those numbers. We will report them honestly, whether they're moving the right direction or not.

**[Pause. One breath. Deliver this slowly.]**

We are a small team with a large mandate.

We are aware of both facts.

---

## SLIDE 13 — Closing
**⏱️ 2–3 minutes**

---

**[Lean slightly toward the camera. This is the landing. Unhurried. Don't let the energy drop — but don't rush to fill space either.]**

We are the Signal Team now.

Not a team that manages two platforms. Not a team you call after something is already broken and the business is already waiting. A team that builds the foundation that makes incidents shorter, recoveries faster, and business impact smaller.

Stabilize. Standardize. Optimize. That's the sequence. That's the commitment.

**[Final self-deprecating beat. This should sound like genuine honesty at the end of a real conversation — not a scripted closer.]**

I'll be transparent with you about something. I came into this with two mature platforms, a re-org still finding its shape, some meaningful operational gaps, and a mandate that is, to put it honestly, quite large for the size of the team I have.

And my instinct was to book a 50-minute Teams call with the entire organization and explain exactly what the gaps are.

That is either the most confident thing I've done professionally, or evidence that my self-awareness has some of the same gaps as our observability coverage.

I'm choosing to call it confident.

**[One beat. Then close with energy — clarity, conviction, no trailing off.]**

The mean time to detect what's wrong, and the mean time to get back to operational — those numbers are longer than they should be, and they're costing the business every time an incident runs long. We know where the gaps are. We know how to close them. And we know we need this room to help us do it.

Thank you for the time. Let's take some questions.

---
---

## Q&A SECTION
**⏱️ 10 minutes**

---

### Virtual Q&A on MS Teams

- Use the Q&A feature or chat — have **[contact name]** surface questions so you're not reading chat while talking
- If Q&A is quiet at the start, open it yourself with a thread you know is on people's minds: *"One thing I expect is on some minds is the timeline for when engineers will actually notice a difference during incidents — let me address that while questions come in."*
- For long or compound questions: *"Let me make sure I'm answering the right part — I'll start with..."*
- For questions from business colleagues that need translation: bridge the technical answer to the business outcome before finishing

**Closing Q&A:**
*"Good place to stop. Anything we didn't get to — my contact is on the closing slide. Recording and slides go to all registrants within 24 hours. Thanks for the time."*

---

### Bridge Phrases for Tough Questions

1. **"That's a fair question, and I'd rather give you an honest answer than a fast one."**
   *(Use for: trust issues, past incidents, broken expectations.)*

2. **"The short answer is [X]. The more useful answer is [Y]."**
   *(Use for: AI timeline, scope, resourcing questions.)*

3. **"I know what I know and I know what I don't — on [X] I can tell you [Y], and I'll follow up on the rest."**
   *(Use for: specific technical or data questions you don't have complete answers for.)*

4. **"That's exactly the situation the standards framework is designed to prevent. Here's how specifically."**
   *(Use for: engineers or managers citing real incidents as examples.)*

5. **"If you're asking whether we're where I want us to be — no. If you're asking whether we have a clear path — yes. Here's what that looks like."**
   *(Use for: skeptical stakeholders pressing on credibility or timelines.)*

---

### Prepared Responses to Common Tough Questions

**Q: "What's the timeline before engineers actually notice a difference during incidents?"**
> Q1 and Q2 is the alert and instrumentation audit. By the end of Q2, every alert in Elastic should have a runbook attached and a clear owner. For engineers on call, that's a direct change to incident experience — you open an incident and the context is already there. Q3 and Q4 is when the first observability-to-automation integration patterns go live for defined incident types. That's when you start seeing specific recovery steps execute without manual intervention. The full flywheel — where MTTD and MTTR are measurably and consistently shorter — is the Standardize phase outcome.

**Q: "Sometimes incidents are opened by users before our tools catch them. How does this fix that?"**
> That's one of the clearest indicators that our observability coverage has gaps — and the instrumentation standards in the Stabilize phase are specifically designed to close them. Every production application meeting the baseline means we are not waiting for a user to tell us something is wrong. Detection before user impact is the target. It won't happen overnight, but it will happen service by service as we work through the onboarding queue.

**Q: "Why should the business trust automation given it has contributed to incidents?"**
> Fair and important question. Automation contributed to incidents because changes reached production without full impact assessment and without review. That is a governance failure, not a platform failure. The peer review requirement and the change control integration we're building exist specifically to prevent that. I am not asking for trust based on what I'm saying today. I'm asking you to hold us to the standards we're publishing and watch the incident trend over the next two quarters. The proof is in the numbers, not in this presentation.

**Q: "You said small team with a large mandate — can you actually deliver this?"**
> Stabilize is achievable with current headcount if we get the organizational partnership I described. The scope is defined and the work is in motion. Standardize will require a resourcing conversation, and I'll have it openly before we hit a capacity wall — not quietly after we've already missed something. If we need more resources to deliver what's on the roadmap, I'll say so directly. I'm not going to manage that situation by hoping nobody notices.

**Q: "How will you measure and report on progress?"**
> Three numbers: mean time to detect, mean time to resolve, and incidents that didn't reach users because they were caught and resolved before impact. We'll report those metrics in the executive KPI dashboard in the Standardize phase, and we'll report them honestly — whether they're moving the right direction or not. If they're not moving, that's a conversation we need to have, and I'd rather have it with data than without it.

---

*End of delivery script.*

---

**Before you present:**
- Replace `[Your Name]` throughout
- Replace `[contact name]` in Slides 12 and Q&A sections
- Replace `[Date]` on Slide 1
- **Slide 10 (North Star)** — the five-second silence after "The user never noticed anything was wrong" is the most important moment in the talk. Hold it. The room will fill it in their own heads.
- Send recording and slides to all registrants within 24 hours
- Total estimated delivery: **46–50 minutes**
