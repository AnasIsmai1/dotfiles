import type { AgentInfo, Register, SessionUsage } from 'claude-code'

const PANE = 'agent-dash'
const STALE_MS = 600000
const COLS = ['spec', 'build', 'test', 'review', 'verify']
// which column a role's agent sits in; anything else goes under its parent or the current stage
const ROLE: Record<string, string> = { planner: 'spec', coder: 'build', tester: 'test', 'pr-reviewer': 'review', 'qa-tester': 'review', dave: 'verify' }
const MARK: Record<string, string> = { running: '●', done: '✓', failed: '✗', stale: '?', idle: '◌', waiting: '◐', pending: '○' }

// status.json and journals come from the repo/disk: strip control chars (terminal escapes) before drawing
export const clean = (v: unknown) => (v == null ? '' : String(v)).replace(/[\x00-\x1f\x7f-\x9f]/g, '')

type Status = { track?: string; engine?: string; stage?: string; round?: number; verdict?: string | null }
type State = 'running' | 'done' | 'failed' | 'stale'
type Group = { phase: string; agents: { label: string; state: State }[] }
type Run = { id: string; name: string; groups: Group[] }
type Card = { text: string; state: string }
type Column = { stage: string; mark: 'done' | 'current' | 'todo'; cards: Card[] }

const agentState = (a: AgentInfo) => ({ completed: 'done', failed: 'failed', killed: 'failed' } as Record<string, string>)[a.status] ?? a.status
const nameOf = (a: AgentInfo) => clean(a.teammateId?.split('@')[0] ?? a.type)

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


const count = (groups: Group[], st: State) => groups.reduce((n, g) => n + g.agents.filter(a => a.state === st).length, 0)
export const runningCount = (groups: Group[]) => count(groups, 'running')

export const bar = (done: number, total: number, cells = 6) => {
  const n = total ? Math.round((Math.min(done, total) / total) * cells) : 0
  return '▰'.repeat(n) + '▱'.repeat(cells - n)
}

export function header(s: Status | null) {
  if (!s || !s.stage) return null
  const verdict = clean(s.verdict)
  return `ship · ${clean(s.track) || '?'}/${clean(s.engine) || '?'} · round ${Number(s.round) || 1}${verdict ? ` · ${verdict}` : ''}`
}

// One column per stage; agents grouped by role, repeats folded into "name ×n"
export function boardColumns(s: Status | null, agents: AgentInfo[]): Column[] {
  const stage = clean(s?.stage)
  const at = COLS.indexOf(stage)
  const finished = stage === 'release' || stage === 'done'
  const colOf = new Map<string, string>()
  const place = (a: AgentInfo): string => {
    if (colOf.has(a.id)) return colOf.get(a.id)!
    const parent = a.parentId ? agents.find(p => p.id === a.parentId) : undefined
    const c = ROLE[nameOf(a)] ?? ROLE[a.type] ?? (parent ? place(parent) : at >= 0 ? stage : 'spec')
    colOf.set(a.id, c)
    return c
  }
  return COLS.map((col, i) => {
    const mine = agents.filter(a => place(a) === col)
    const byName = new Map<string, string[]>()
    for (const a of mine) byName.set(nameOf(a), [...(byName.get(nameOf(a)) ?? []), agentState(a)])
    const cards = [...byName].map(([name, states]) => {
      const state = states.includes('running') ? 'running' : states.includes('failed') ? 'failed' : states.every(x => x === 'done') ? 'done' : states[0]
      return { text: `${name}${states.length > 1 ? ` ×${states.length}` : ''} ${MARK[state] ?? '·'}`, state }
    })
    const mark = finished || (at >= 0 && i < at) ? 'done' : i === at ? 'current' : 'todo'
    return { stage: col, mark, cards }
  })
}

export function runLine(r: Run) {
  const total = r.groups.reduce((n, g) => n + g.agents.length, 0)
  const ended = count(r.groups, 'done') + count(r.groups, 'failed')
  const tail = [count(r.groups, 'running') && `${count(r.groups, 'running')} running`, count(r.groups, 'failed') && `${count(r.groups, 'failed')} failed`].filter(Boolean).join(' · ')
  return `${r.name}  ${bar(ended, total)}  ${ended}/${total} agents${tail ? `   ${tail}` : ''}`
}

export function usageLine(u: SessionUsage | null) {
  const parts = [
    ...(u?.rateLimits ?? []).map(r => `${({ five_hour: '5h', seven_day: '7d' } as Record<string, string>)[r.kind] ?? r.kind} ${Math.round(r.percentUsed)}%`),
    u?.context?.percent != null ? `ctx ${Math.round(u.context.percent)}%` : '',
    u?.cost ? `$${u.cost.usd.toFixed(2)}` : '',
  ].filter(Boolean)
  return parts.length ? parts.join('  ') : null
}

const stageActive = (s: Status | null) => !!s?.stage && s.stage !== 'done'
const wfRunning = (runs: Run[]) => runs.reduce((n, r) => n + runningCount(r.groups), 0)
export const isActive = (s: Status | null, runs: Run[]) => stageActive(s) || wfRunning(runs) > 0

// Band: one compact line, Tickloop-style
export function bandLine(s: Status | null, agents: AgentInfo[], runs: Run[]) {
  if (!isActive(s, runs)) return null
  const n = agents.filter(a => a.status === 'running').length + wfRunning(runs)
  const tail = n ? ` · ${n} running` : ''
  if (stageActive(s)) {
    const stage = clean(s!.stage)
    const i = COLS.indexOf(stage)
    return `ship ${clean(s!.track) || '?'}/${clean(s!.engine) || '?'}  ${bar(i < 0 ? 0 : i, COLS.length, COLS.length)}  ${stage}${tail}`
  }
  const r = runs.find(x => runningCount(x.groups) > 0)!
  const total = r.groups.reduce((m, g) => m + g.agents.length, 0)
  return `${r.name}  ${bar(count(r.groups, 'done') + count(r.groups, 'failed'), total)}${tail}`
}

const readStatus = async ($: any): Promise<Status | null> => {
  try { return JSON.parse(await $.fs.read('.pipeline/status.json')) } catch { return null }
}

const readRuns = async ($: any): Promise<Run[]> => {
  const cwd = await $.session.cwd()
  const session = `${await $.env.get('HOME')}/.claude/projects/${cwd.replace(/[^A-Za-z0-9]/g, '-')}/${await $.session.id()}`
  const base = `${session}/subagents/workflows`
  let dirs: { name: string; kind: string }[]
  try { dirs = await $.fs.list(base) } catch { return [] }
  let scripts: { name: string }[] = []
  try { scripts = await $.fs.list(`${session}/workflows/scripts`) } catch {}
  const nameFor = (id: string) => clean(scripts.find(f => f.name.endsWith(`-${id}.js`))?.name.slice(0, -(id.length + 4)) || id)
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
      if (groups.length) runs.push({ id: r.id, name: nameFor(r.id), groups })
    } catch {}
  }
  return runs
}

let wasActive = false
const COLOR: Record<string, string> = { running: 'green', failed: 'red', idle: 'yellow', waiting: 'yellow' }

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
    const head = header(s)
    const u = usageLine(usage)
    const width = Math.max(40, (e.props as any)?.bodyColumns ?? 80)
    const rule = <Text dimColor>{'─'.repeat(width)}</Text>
    if (!head && !runs.length && !agents.length) return <Text dimColor>{`no active runs${u ? `   ${u}` : ''}`}</Text>
    const cols = head || agents.length ? boardColumns(s, agents) : []
    const colW = Math.floor(width / COLS.length)
    return (
      <Box flexDirection="column">
        <Box flexDirection="row" justifyContent="space-between">
          <Text bold color="cyan">{head ?? 'agents'}</Text>
          {u && <Text dimColor>{u}</Text>}
        </Box>
        {cols.length > 0 && rule}
        {cols.length > 0 && (
          <Box flexDirection="row">
            {cols.map(c => (
              <Box flexDirection="column" width={colW}>
                <Text bold={c.mark === 'current'} color={c.mark === 'current' ? 'cyan' : undefined} dimColor={c.mark === 'todo'} wrap="truncate-end">
                  {`${c.stage.toUpperCase()}${c.mark === 'done' ? ' ✓' : c.mark === 'current' ? ' ●' : ''}`}
                </Text>
                {c.cards.length === 0 && <Text dimColor>·</Text>}
                {c.cards.map(k => <Text color={COLOR[k.state]} dimColor={k.state === 'done' || k.state === 'stale'} wrap="truncate-end">{k.text}</Text>)}
              </Box>
            ))}
          </Box>
        )}
        {runs.length > 0 && rule}
        {runs.map(r => (
          <Box flexDirection="column">
            <Text wrap="truncate-end"><Text dimColor>workflow  </Text>{runLine(r)}</Text>
            {r.groups.flatMap(g => g.agents.filter(a => a.state === 'running' || a.state === 'failed')).slice(0, 4).map(a => (
              <Text color={COLOR[a.state]} wrap="truncate-end">{`  ${MARK[a.state]} ${a.label}`}</Text>
            ))}
          </Box>
        ))}
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
