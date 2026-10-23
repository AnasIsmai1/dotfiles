import type { AgentInfo, Register, SessionUsage } from 'claude-code'

const PANE = 'agent-dash'
const STALE_MS = 600000
const STAGES = ['spec', 'build', 'test', 'review', 'verify', 'release']
const ICON: Record<string, string> = { running: '●', waiting: '◐', pending: '○', idle: '◌', completed: '✓', failed: '✗', killed: '✗' }

// status.json and journals come from the repo/disk: strip control chars (terminal escapes) before drawing
export const clean = (v: unknown) => (v == null ? '' : String(v)).replace(/[\x00-\x1f\x7f-\x9f]/g, '')

type Status = { track?: string; engine?: string; stage?: string; round?: number; verdict?: string | null }
type Group = { phase: string; agents: { label: string; state: 'running' | 'done' | 'failed' | 'stale' }[] }
type Run = { id: string; groups: Group[] }

// Lines of the tree: children under their parent, live ones first, finished ones dimmed.
export function treeLines(agents: AgentInfo[], keepDone = 8) {
  const live = (a: AgentInfo) => !['completed', 'failed', 'killed'].includes(a.status)
  const done = agents.filter(a => !live(a)).slice(-keepDone)
  const shown = agents.filter(a => live(a) || done.includes(a))
  const ids = new Set(shown.map(a => a.id))
  const kids = (parent?: string) => shown
    .filter(a => (a.parentId && ids.has(a.parentId) ? a.parentId : undefined) === parent)
    .sort((a, b) => Number(live(b)) - Number(live(a)))
  const out: { text: string; dim: boolean }[] = []
  const walk = (parent: string | undefined, pre: string) => {
    const list = kids(parent)
    list.forEach((a, i) => {
      const last = i === list.length - 1
      const name = clean(a.teammateId?.split('@')[0] ?? a.type)
      out.push({ text: `${pre}${last ? '└─' : '├─'} ${ICON[a.status] ?? '·'} ${name} — ${clean(a.description)}`.slice(0, 160), dim: !live(a) })
      walk(a.id, pre + (last ? '   ' : '│  '))
    })
  }
  walk(undefined, '')
  return out
}

export function stageLine(s: Status | null) {
  if (!s || !s.stage) return null
  s = { track: clean(s.track) || '?', engine: clean(s.engine) || '?', stage: clean(s.stage), round: Number(s.round) || 1, verdict: clean(s.verdict) }
  const strip = STAGES.map(x => (x === s.stage ? `[${x}]` : x)).join(' › ')
  const pre = STAGES.includes(s.stage) ? '' : `[${s.stage}] · `
  return `ship ${s.track ?? '?'}/${s.engine ?? '?'}  ${pre}${strip}  r${s.round ?? 1}${s.verdict ? '  ' + s.verdict : ''}`
}

export function workflowGroups(text: string, mtimes: Record<string, number>, now: number): Group[] {
  const phases = new Set<string>()
  const info = new Map<string, { phase: string; label: string; end: 'done' | 'failed' | null }>()
  for (const line of text.split('\n')) {
    let o: any
    try { o = JSON.parse(line) } catch { continue }
    if (!o || typeof o !== 'object' || typeof o.agentId !== 'string') continue
    if (o.type === 'started') {
      if (info.has(o.agentId)) continue
      const phase = clean(o.phase) || '(no phase)'
      phases.add(phase)
      info.set(o.agentId, { phase, label: clean(o.label || o.agentId), end: null })
    } else if (o.type === 'result' || o.type === 'failed') {
      const a = info.get(o.agentId)
      if (a && !a.end) a.end = o.type === 'result' ? 'done' : 'failed'
    }
  }
  return [...phases].map(phase => ({
    phase,
    agents: [...info].filter(([, a]) => a.phase === phase).map(([id, a]) => ({
      label: a.label,
      state: a.end ?? (now - (mtimes[id] ?? 0) <= STALE_MS ? 'running' as const : 'stale' as const),
    })),
  }))
}

export const runningCount = (groups: Group[]) => groups.reduce((n, g) => n + g.agents.filter(a => a.state === 'running').length, 0)

export function usageLine(u: SessionUsage | null) {
  const parts = [
    u?.context?.percent != null ? `ctx ${Math.round(u.context.percent)}%` : '',
    u?.cost ? `$${u.cost.usd.toFixed(2)}` : '',
    ...(u?.rateLimits ?? []).map(r => `${({ five_hour: '5h', seven_day: '7d' } as Record<string, string>)[r.kind] ?? r.kind} ${Math.round(r.percentUsed)}%`),
  ].filter(Boolean)
  return parts.length ? parts.join(' · ') : null
}

const stageActive = (s: Status | null) => !!s?.stage && s.stage !== 'done'
const wfRunning = (runs: Run[]) => runs.reduce((n, r) => n + runningCount(r.groups), 0)
export const isActive = (s: Status | null, runs: Run[]) => stageActive(s) || wfRunning(runs) > 0

export function bandLine(s: Status | null, agents: AgentInfo[], runs: Run[]) {
  if (!isActive(s, runs)) return null
  const n = agents.filter(a => a.status === 'running').length + wfRunning(runs)
  return `${stageActive(s) ? stageLine(s) : 'workflow'}${n ? ` · ${n} running` : ''}`
}

const readStatus = async ($: any): Promise<Status | null> => {
  try { return JSON.parse(await $.fs.read('.pipeline/status.json')) } catch { return null }
}

const readRuns = async ($: any): Promise<Run[]> => {
  const cwd = await $.session.cwd()
  const base = `${await $.env.get('HOME')}/.claude/projects/${cwd.replace(/[^A-Za-z0-9]/g, '-')}/${await $.session.id()}/subagents/workflows`
  let dirs: { name: string; kind: string }[]
  try { dirs = await $.fs.list(base) } catch { return [] }
  const now = await $.clock.now()
  const found: { id: string; mtime: number; mtimes: Record<string, number> }[] = []
  for (const d of dirs.filter(d => d.kind === 'dir')) {
    let files: { name: string; mtimeMs: number }[]
    try { files = await $.fs.list(`${base}/${d.name}`) } catch { continue }
    const j = files.find(f => f.name === 'journal.jsonl')
    if (!j) continue
    const mtimes: Record<string, number> = {}
    for (const f of files) {
      const m = /^agent-(.+)\.jsonl$/.exec(f.name)
      if (m) mtimes[m[1]] = f.mtimeMs
    }
    found.push({ id: d.name, mtime: j.mtimeMs, mtimes })
  }
  const runs: Run[] = []
  // newest first; a run with nothing started yet doesn't take one of the 2 slots
  for (const r of found.sort((a, b) => b.mtime - a.mtime)) {
    if (runs.length === 2) break
    try {
      const groups = workflowGroups(await $.fs.read(`${base}/${r.id}/journal.jsonl`), r.mtimes, now)
      if (groups.length) runs.push({ id: r.id, groups })
    } catch {}
  }
  return runs
}

let wasActive = false

export const register: Register = on => {
  let timer: { cancel: () => void } | null = null

  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'dash', description: 'Show the agent dashboard pane' })
    timer?.cancel()
    timer = $.clock.every(1500, async () => {
      const active = isActive(await readStatus($), await readRuns($))
      if (active && !wasActive) void $.ui.open({ id: PANE, title: 'Dash' })
      wasActive = active
      $.ui.invalidate('ui.render')
    })
    return next(e)
  })

  on('command.run', { command: 'dash' }, async $ => {
    await $.ui.open({ id: PANE, title: 'Dash' })
    return { text: 'Dash opened.' }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const [s, agents, runs, usage] = await Promise.all([
      readStatus($), $.agent.list(), readRuns($), $.session.usage().catch(() => null),
    ])
    const stage = stageLine(s)
    const lines = treeLines(agents)
    const u = usageLine(usage)
    if (!stage && !lines.length && !runs.length && !u) return <Text dimColor>idle</Text>
    const mark = { running: '●', done: '✓', failed: '✗', stale: '?' }
    return (
      <Box flexDirection="column">
        {stage && <Text color="cyan">{stage}</Text>}
        {lines.length > 0 && <Text bold>◆ lead (this session)</Text>}
        {lines.map(l => <Text dimColor={l.dim}>{'   ' + l.text}</Text>)}
        {runs.map(r => (
          <Box flexDirection="column">
            <Text bold>{`${clean(r.id)}  ${runningCount(r.groups)} running`}</Text>
            {r.groups.map(g => (
              <Box flexDirection="column">
                <Text>{'  ' + g.phase}</Text>
                {g.agents.map(a => <Text dimColor={a.state === 'done' || a.state === 'stale'}>{`    ${mark[a.state]} ${a.label}`.slice(0, 160)}</Text>)}
              </Box>
            ))}
          </Box>
        ))}
        {u && <Text dimColor>{u}</Text>}
      </Box>
    )
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)
    const [s, agents, runs] = await Promise.all([readStatus($), $.agent.list(), readRuns($)])
    const line = bandLine(s, agents, runs)
    if (!line) return next(e)
    const { Text } = $.ui.resolve(e)
    return <Text color="cyan" wrap="truncate-end">{line}</Text>
  })
}
