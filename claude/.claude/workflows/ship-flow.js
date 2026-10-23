export const meta = {
  name: 'ship-flow',
  description: 'Plan (Opus) → build/test (Sonnet, planted failures) → browser QA → review with adversarial verify',
  whenToUse: 'Ship a scoped feature or fix end to end in the current repo. Use /ship as the front door; it grills requirements first. Args: {feature, brief?, url?, criteria?}',
  phases: [
    { title: 'Plan', detail: 'Opus writes a schema spec; stops on open questions' },
    { title: 'Build', detail: 'Sonnet implements, tests with 3 planted failures, fix loop capped', model: 'sonnet' },
    { title: 'QA', detail: 'qa-tester runs the acceptance criteria in a headless browser', model: 'sonnet' },
    { title: 'Review', detail: 'pr-reviewer finds, dave refutes each finding' },
  ],
}

const A = typeof args === 'string' ? { feature: args } : (args || {})
if (!A.feature) throw new Error('ship-flow needs args.feature')

const SPEC = {
  type: 'object',
  required: ['openQuestions', 'summary', 'files', 'acceptance', 'edgeCases', 'testCommand'],
  properties: {
    openQuestions: { type: 'array', items: { type: 'string' } },
    summary: { type: 'string' },
    files: { type: 'array', items: { type: 'object', required: ['path', 'change'], properties: { path: { type: 'string' }, change: { type: 'string' } } } },
    patterns: { type: 'array', items: { type: 'string' } },
    acceptance: { type: 'array', items: { type: 'string' } },
    edgeCases: { type: 'array', items: { type: 'string' } },
    testCommand: { type: 'string' },
    uiUrl: { type: 'string' },
  },
}
const TESTS = {
  type: 'object',
  required: ['passed', 'failures', 'plantedRejected'],
  properties: {
    passed: { type: 'boolean' },
    failures: { type: 'array', items: { type: 'string' } },
    plantedRejected: { type: 'integer', description: 'how many of the 3 planted wrong variants the tests caught' },
    testFiles: { type: 'array', items: { type: 'string' } },
  },
}
const QA = {
  type: 'object',
  required: ['gate', 'fails'],
  properties: {
    gate: { type: 'string', enum: ['PASS', 'CONCERNS', 'FAIL'] },
    fails: { type: 'array', items: { type: 'string' } },
    report: { type: 'string' },
  },
}
const FINDINGS = {
  type: 'object',
  required: ['findings'],
  properties: {
    findings: { type: 'array', items: { type: 'object', required: ['file', 'severity', 'claim'], properties: {
      file: { type: 'string' }, line: { type: 'integer' },
      severity: { type: 'string', enum: ['critical', 'high', 'med', 'low'] }, claim: { type: 'string' },
    } } },
  },
}
const VERDICT = {
  type: 'object',
  required: ['refuted', 'reason'],
  properties: { refuted: { type: 'boolean' }, reason: { type: 'string' } },
}

phase('Plan')
const spec = await agent(
  `Write an implementation spec for: ${A.feature}
${A.criteria ? `Acceptance criteria from the user:\n${A.criteria}\n` : ''}
Read the code the change touches first, then follow the repo's patterns (name the file to copy from in "patterns").
${A.brief ? `Agreed brief (already grilled with the user; treat it as settled):\n${A.brief}\n` : ''}
Spec the minimum that works, using the ponytail ladder: does it need to exist at all → reuse what's in the repo → stdlib → native platform feature → an already-installed dep → one line → only then new code.
Put anything ambiguous in openQuestions; don't guess. Put speculative scope out of scope.
testCommand is the exact command that runs the relevant tests. If the change has a UI, set uiUrl to the local URL to check.`,
  { label: 'planner', schema: SPEC, effort: 'high' },
)
if (!spec) return { status: 'BLOCKED', reason: 'planner agent failed (usage limit or API error)' }
if (spec.openQuestions.length) return { status: 'NEEDS ANSWERS', openQuestions: spec.openQuestions, spec }
const specText = JSON.stringify(spec, null, 2)

phase('Build')
let changes = await agent(
  `Implement this spec exactly. No features it didn't ask for, no refactors outside scope.
Ponytail: shortest working diff, reuse before writing, no new deps where stdlib or the platform will do, no scaffolding "for later". Mark deliberate corner-cuts with a "ponytail:" comment naming the limit.
${specText}
Return a short summary: files changed and what each change does.`,
  { label: 'coder', model: 'sonnet' },
)
// a failed agent (usage limit, API error) resolves to null: stop with a reason instead of crashing
const halt = (who) => ({ status: 'BLOCKED', reason: `${who} agent failed (usage limit or API error); resume this run once it clears`, spec })
if (!changes) return halt('coder')

const runTests = (round) => agent(
  `Test this change. Spec:\n${specText}\nCoder summary:\n${changes}
1. Write or extend tests for the acceptance criteria and edge cases. Use the repo's framework; add no new test deps.
2. Run: ${spec.testCommand}
3. Planted failures: one at a time, temporarily change one constant, swap one branch, and shift one boundary by one in the implementation. Run the tests on each, record whether they were caught, and revert each change. Confirm with git diff that nothing planted is left behind.
4. Report the failures verbatim. Do not fix the implementation.`,
  { label: `tester r${round}`, model: 'sonnet', schema: TESTS },
)

// ponytail: one coder in the working tree; switch to per-file isolation:'worktree' agents once specs regularly touch 5+ independent files
let tests = await runTests(1)
if (!tests) return halt('tester r1')
let best = tests.failures.length, stale = 0, round = 1
while ((!tests.passed || tests.plantedRejected < 3) && stale < 2) {
  round++
  changes = await agent(
    `Fix these test results without weakening the tests.
Failures:\n${tests.failures.join('\n') || '(none)'}
Planted failures caught: ${tests.plantedRejected}/3. If below 3, the tests are too weak: strengthen the tests, not the code.
Spec:\n${specText}`,
    { label: `fixer r${round}`, model: 'sonnet' },
  )
  if (!changes) return halt(`fixer r${round}`)
  tests = await runTests(round)
  if (!tests) return halt(`tester r${round}`)
  if (tests.failures.length < best) { best = tests.failures.length; stale = 0 } else stale++
}

let qa = null
const qaUrl = A.url || spec.uiUrl
if (qaUrl) {
  phase('QA')
  qa = await agent(
    `Engine: headless. Target: ${qaUrl}
Acceptance criteria:\n${spec.acceptance.map(c => '- ' + c).join('\n')}
Edge cases:\n${spec.edgeCases.map(c => '- ' + c).join('\n')}
Run your full method and return the gate.`,
    { label: 'qa-tester', agentType: 'qa-tester', schema: QA },
  )
} else log('QA skipped: no url arg and the spec has no uiUrl')

phase('Review')
// barrier: verify runs once over the merged findings from both lenses
const reviews = (await parallel([
  () => agent(
    `Review the working-tree changes (git diff) against this spec. Report only real correctness, security, and spec-mismatch issues.
${specText}`,
    { label: 'pr-reviewer', phase: 'Review', agentType: 'pr-reviewer', schema: FINDINGS },
  ),
  () => agent(
    `Load the ponytail-review skill with the Skill tool and apply it to the working-tree changes (git diff). Report each over-engineering finding (delete / stdlib / native / yagni / shrink) as severity "low", or "med" if it adds a dependency or a new abstraction layer. Put the tag and the replacement in the claim.`,
    { label: 'ponytail-review', phase: 'Review', model: 'sonnet', schema: FINDINGS },
  ),
])).filter(Boolean)
const review = { findings: reviews.flatMap(r => r.findings) }
const confirmed = (await pipeline(review.findings, f =>
  agent(
    `Try to refute this review finding. Read the code yourself. Default to refuted=true if you can't confirm it in the code.
${f.file}${f.line ? ':' + f.line : ''} [${f.severity}] ${f.claim}`,
    { label: `verify ${f.file}`, phase: 'Review', agentType: 'dave', schema: VERDICT },
  ).then(v => (v && !v.refuted ? { ...f, why: v.reason } : null)),
)).filter(Boolean)

const blocking = confirmed.some(f => f.severity === 'critical' || f.severity === 'high')
const verdict = !tests.passed || blocking || qa?.gate === 'FAIL' ? 'BLOCK'
  : tests.plantedRejected < 3 || confirmed.length || qa?.gate === 'CONCERNS' ? 'NEEDS WORK' : 'SHIP'

return {
  verdict,
  summary: spec.summary,
  changes,
  tests: { passed: tests.passed, plantedRejected: `${tests.plantedRejected}/3`, failures: tests.failures, rounds: round },
  qa,
  findings: confirmed,
  droppedFindings: review.findings.length - confirmed.length,
  note: 'Nothing committed. Review the diff before merging.',
}
