# Anti-Pattern Catalog

Common anti-patterns in AI workflow assets. The `super-auditor` should flag these when found. Each entry includes the pattern, why it's harmful, and what the fix looks like.

---

## AP-1: Unbounded Tool Scope

**Pattern:** Asset grants access to all tools or uses broad permissions without justification.

```markdown
Use any tools you need to complete the task.
```

**Risk:** Safety — the asset can read secrets, write files, run commands, or access the network without constraint.

**Fix:** Declare only the tools needed in YAML frontmatter `tools:` and justify each one.

---

## AP-2: Recursive Self-Delegation

**Pattern:** Asset instructs itself to be invoked again, creating potential infinite loops.

```markdown
If the task is complex, invoke this agent again on each sub-task.
```

**Risk:** Behavioral correctness — unbounded recursion wastes context, causes loops, and produces unpredictable output.

**Fix:** Delegate to a different, specialized agent. If self-recursion is truly needed, add explicit depth limits and termination conditions.

---

## AP-3: Hardcoded Secrets or Paths

**Pattern:** Asset references absolute file paths, API keys, or credentials.

```markdown
Read the config at C:\Users\admin\.secrets\api-keys.json
```

**Risk:** Safety + Maintainability — secrets leak into version control; paths break on other machines.

**Fix:** Use environment variables or configuration parameters. Never embed secrets in prompt files.

---

## AP-4: Missing Uncertainty Handling

**Pattern:** Asset has no instructions for what to do when input is missing, ambiguous, or unexpected.

```markdown
Read the file and produce a report.
(no mention of what happens if the file doesn't exist)
```

**Risk:** Behavioral correctness — the model guesses, hallucinates, or produces misleading output.

**Fix:** Add explicit handling: "If the file cannot be read, report the error and stop."

---

## AP-5: Undefined Inputs and Outputs

**Pattern:** Asset describes what it does but not what it expects or produces.

```markdown
You are a code reviewer. Review the code and provide feedback.
```

**Risk:** Behavior correctness + Clarity — every invocation may interpret "review" and "feedback" differently.

**Fix:** Define the exact input format and output structure.

---

## AP-6: Circular Delegation Chain

**Pattern:** Agent A delegates to Agent B, which delegates back to Agent A.

```text
agent-A → command-B → agent-A
```

**Risk:** Behavioral correctness — infinite delegation loop; context exhaustion.

**Fix:** Break the cycle. If both agents need each other's capabilities, extract the shared logic into a third agent or shared reference.

---

## AP-7: Conflicting Instructions

**Pattern:** Asset contains contradictory rules.

```markdown
Never modify files.
...
Write the corrected version to the same file path.
```

**Risk:** Behavioral correctness — the model must choose which rule to follow; behavior becomes unpredictable.

**Fix:** Remove the contradiction. If both behaviors are needed conditionally, make the conditions explicit and mutually exclusive.

---

## AP-8: Vague Fallback Behavior

**Pattern:** Asset says to "do your best" or "try something" when conditions are unclear.

```markdown
If you're not sure, just try something and see what happens.
```

**Risk:** Safety + Behavior — encourages speculative actions that may be destructive or incorrect.

**Fix:** Replace with specific fallback: "If uncertain, report the ambiguity and stop. Do not guess."

---

## AP-9: Overly Broad Purpose

**Pattern:** Asset tries to handle everything rather than having a focused scope.

```markdown
You are a universal assistant. Handle any request related to code, documentation,
testing, deployment, security, and project management.
```

**Risk:** Maintainability + Clarity — impossible to audit for correctness; behavior varies wildly by input.

**Fix:** Split into focused, single-purpose assets. Each asset should have one clear job.

---

## AP-10: Hidden Autonomous Actions

**Pattern:** Asset performs actions (file writes, network calls, git operations) without informing the user.

```markdown
Silently fix any issues found and commit the changes.
```

**Risk:** Safety — irreversible changes made without user awareness or consent.

**Fix:** All actions that modify state must be visible and require explicit user confirmation.
