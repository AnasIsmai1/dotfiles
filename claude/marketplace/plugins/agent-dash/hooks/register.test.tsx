import { expect, mock, test } from 'claude-code/testing'
import { bandLine, clean, isActive, stageLine, treeLines, usageLine, workflowGroups } from './register'

const a = (id: string, status: string, parentId?: string, teammateId?: string) =>
  ({ id, status, parentId, teammateId, type: id, description: `job ${id}` }) as any

const J = [
  '{"type":"launched","agentId":"x"}',
  '{"type":"started","agentId":"d1","phase":"Design","label":"designer"}',
  '{"type":"result","agentId":"d1"}',
  '{"type":"started","agentId":"e1","phase":"Execute","label":"coder A"}',
  '{"type":"started","agentId":"e2","phase":"Execute"}',
  '{not json',
  '42',
  '{"type":"result","agentId":"nope"}',
].join('\n')
const NOW = 1_000_000
const runs = (m: Record<string, number>) => [{ id: 'r', groups: workflowGroups(J, m, NOW) }]

test('workflowGroups', () => {
  const g = workflowGroups(J, { e1: NOW - 1000, e2: NOW - 600001 }, NOW)
  expect(g).toEqual([
    { phase: 'Design', agents: [{ label: 'designer', state: 'done' }] },
    { phase: 'Execute', agents: [{ label: 'coder A', state: 'running' }, { label: 'e2', state: 'stale' }] },
  ])
  expect(workflowGroups(J, {}, NOW)[1].agents.map(x => x.state)).toEqual(['stale', 'stale'])
  expect(workflowGroups('', {}, NOW)).toEqual([])
})

test('stageLine', () => {
  expect(stageLine(null)).toBeNull()
  expect(stageLine({})).toBeNull()
  expect(stageLine({ track: 'feature', engine: 'team', stage: 'test', round: 2 })).toBe('ship feature/team  spec › build › [test] › review › verify › release  r2')
  expect(stageLine({ track: 'f', engine: 'e', stage: 'grill' })).toContain('[grill] · spec › build')
  expect(stageLine({ track: 'f', engine: 'e', stage: 'done', round: 3, verdict: 'SHIP' })).toBe('ship f/e  [done] · spec › build › test › review › verify › release  r3  SHIP')
})

test('usageLine', () => {
  const u = { context: { percent: 41.2 }, cost: { usd: 1.5 }, rateLimits: [{ kind: 'five_hour', percentUsed: 10 }, { kind: 'seven_day', percentUsed: 20 }, { kind: 'spend_limit', percentUsed: 5 }] } as any
  expect(usageLine(u)).toBe('ctx 41% · $1.50 · 5h 10% · 7d 20% · spend_limit 5%')
  expect(usageLine({ context: {}, rateLimits: [{ kind: 'five_hour', percentUsed: 9 }] } as any)).toBe('5h 9%')
  expect(usageLine({ context: {}, rateLimits: [] } as any)).toBeNull()
  expect(usageLine(null)).toBeNull()
})

test('isActive and bandLine', () => {
  const none = runs({})
  const live = runs({ e1: NOW })
  expect(isActive({ stage: 'done' }, none)).toBe(false)
  expect(bandLine({ stage: 'done' }, [a('x', 'running')], none)).toBeNull()
  expect(bandLine(null, [], live)).toBe('workflow · 1 running')
  expect(bandLine({ track: 't', engine: 'e', stage: 'build' }, [a('x', 'running'), a('y', 'completed')], live)).toBe('ship t/e  spec › [build] › test › review › verify › release  r1 · 2 running')
  expect(bandLine({ track: 't', engine: 'e', stage: 'build' }, [], none)).toMatch(/r1$/)
})

test('nests children under parents, live before done', () => {
  const lines = treeLines([a('planner', 'completed'), a('coder', 'running', undefined, 'coder@t'), a('sub', 'running', 'coder')])
  expect(lines.map(l => l.text)).toEqual(['├─ ● coder — job coder', '│  └─ ● sub — job sub', '└─ ✓ planner — job planner'])
  expect(lines[2].dim).toBe(true)
})

test('orphans whose parent is gone go to the root', () => {
  expect(treeLines([a('x', 'running', 'gone')]).map(l => l.text)).toEqual(['└─ ● x — job x'])
})

const PANE = {
  plugin: 'agent-dash', component: 'Pane', requestId: 'agent-dash', surface: 'terminal',
  props: { title: 'Dash', isFocused: false, bodyColumns: 80, placement: 'dock', scroll: { offset: 0, bodyRows: 40 }, view: {} },
} as const
const BAND = {
  plugin: 'agent-dash', component: 'AbovePrompt', surface: 'terminal',
  props: { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 80, scroll: { offset: 0, bodyRows: 10 }, view: {} },
} as any
const W = '/h/.claude/projects/-p/sid/subagents/workflows'

function world(on: any, status: any, listFails = false) {
  mock.env(on, { HOME: '/h' })
  mock.clock(on, { now: NOW })
  on('session.id', () => ({ value: 'sid' }))
  on('session.cwd', () => ({ value: '/p' }))
  on('fs.read', (_: any, e: any) => {
    if (e.path.endsWith("status.json")) return { value: JSON.stringify(status) }
    return { value: J }
  })
  on('fs.list', (_: any, e: any) => {
    if (listFails) throw new Error('ENOENT')
    if (e.path === W) return { value: [{ name: 'wf_1', kind: 'dir', size: 0, mtimeMs: 0, isLink: false }] }
    return { value: [
      { name: 'journal.jsonl', kind: 'file', size: 1, mtimeMs: NOW, isLink: false },
      { name: 'agent-e1.jsonl', kind: 'file', size: 1, mtimeMs: NOW - 1000, isLink: false },
    ] }
  })
  on('agent.list', () => ({ value: [a('coder', 'running', undefined, 'coder@t')] }))
  on('session.usage', () => ({ value: { startedAt: 0, context: { window: 1, percent: 12 }, rateLimits: [], cost: { usd: 0.5 } } }))
}

test('pane shows stage, tree, runs and usage', async ($, on) => {
  world(on, { track: 't', engine: 'e', stage: 'build' })
  const ui = await $.ui.mount(PANE)
  expect(await ui.find({ type: 'Text', text: /^ship t\/e/ })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: /coder — job coder/ })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: /wf_1  1 running/ })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: /Execute/ })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: /● coder A/ })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: /\? e2/ })).toBeTruthy()
  expect((await ui.find({ type: 'Text', text: /ctx/ }))?.text).toBe('ctx 12% · $0.50')
  await ui.unmount()
})

test('pane keeps the done stage when the workflows dir is missing', async ($, on) => {
  world(on, { track: 't', engine: 'e', stage: 'done', verdict: 'SHIP' }, true)
  const ui = await $.ui.mount(PANE)
  expect(await ui.find({ type: 'Text', text: /\[done\].*SHIP/ })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: /Execute|wf_1/ })).toBeFalsy()
  await ui.unmount()
})

test('band draws the line when active', async ($, on) => {
  world(on, { track: 't', engine: 'e', stage: 'build' })
  const ui = await $.ui.mount(BAND)
  expect((await ui.find({ type: 'Text' }))?.text).toBe('ship t/e  spec › [build] › test › review › verify › release  r1 · 2 running')
  await ui.unmount()
})

test('band falls through when idle or surveying', async ($, on) => {
  world(on, { stage: 'done' }, true)
  on('ui.render', ($: any, e: any) => { const { Text } = $.ui.resolve(e); return <Text>engine</Text> })
  let ui = await $.ui.mount(BAND)
  expect((await ui.find({ type: 'Text' }))?.text).toBe('engine')
  await ui.unmount()
  ui = await $.ui.mount({ ...BAND, props: { ...BAND.props, hasSurvey: true } })
  expect((await ui.find({ type: 'Text' }))?.text).toBe('engine')
  await ui.unmount()
})

test('auto-open fires on the rising edge only', async ($, on) => {
  let status: any = { stage: 'build' }
  const clock = mock.clock(on, { now: NOW })
  mock.env(on, { HOME: '/h' })
  let opens = 0
  on('command.register', () => ({ value: { command: 'dash' } }))
  on('ui.open', () => { opens++; return { value: { isPlaced: true } } })
  on('session.start', (_: any, e: any) => ({ cwd: e.cwd }))
  on('session.id', () => ({ value: 'sid' }))
  on('session.cwd', () => ({ value: '/p' }))
  on('fs.read', () => ({ value: JSON.stringify(status) }))
  on('fs.list', () => { throw new Error('ENOENT') })
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  await clock.advance(1500); await clock.advance(1500)
  expect(opens).toBe(1)
  status = { stage: 'done' }
  await clock.advance(1500)
  expect(opens).toBe(1)
  status = { stage: 'test' }
  await clock.advance(1500)
  expect(opens).toBe(2)
})

test('workflowGroups stale boundary is inclusive at 600000 ms', () => {
  const st = (age: number) => workflowGroups(J, { e1: NOW - age, e2: NOW - age }, NOW)[1].agents.map(x => x.state)
  expect(st(300000)).toEqual(['running', 'running'])
  expect(st(600000)).toEqual(['running', 'running'])
  expect(st(600001)).toEqual(['stale', 'stale'])
})

test('failed is terminal: shown as failed, never counted running', () => {
  const g = workflowGroups('{"type":"started","agentId":"f1","phase":"Build","label":"coder"}\n{"type":"failed","agentId":"f1"}', { f1: NOW }, NOW)
  expect(g).toEqual([{ phase: 'Build', agents: [{ label: 'coder', state: 'failed' }] }])
  expect(isActive(null, [{ id: 'r', groups: g }])).toBe(false)
})

test('runs: newest 2 non-empty by journal mtime; skips no-journal, empty and unreadable runs', async ($, on) => {
  const LAUNCHED = '{"type":"launched"}'
  const dirs: Record<string, number | null> = { a_launched: NOW, b_new: NOW - 1000, c_bad: NOW - 2000, d_old: NOW - 3000, e_older: NOW - 4000, f_nojournal: null }
  mock.env(on, { HOME: '/h' })
  mock.clock(on, { now: NOW })
  on('session.id', () => ({ value: 'sid' }))
  on('session.cwd', () => ({ value: '/p' }))
  on('agent.list', () => ({ value: [] }))
  on('session.usage', () => ({ value: { startedAt: 0, context: {}, rateLimits: [] } }))
  on('fs.read', (_: any, e: any) => {
    if (e.path.endsWith('status.json')) throw new Error('ENOENT')
    if (e.path.includes('/c_bad/')) throw new Error('too big')
    return { value: e.path.includes('/a_launched/') ? LAUNCHED : J }
  })
  on('fs.list', (_: any, e: any) => {
    if (e.path === W) return { value: Object.keys(dirs).map(name => ({ name, kind: 'dir', size: 0, mtimeMs: 0, isLink: false })) }
    const m = dirs[e.path.split('/').pop()]
    return { value: m == null ? [] : [{ name: 'journal.jsonl', kind: 'file', size: 1, mtimeMs: m, isLink: false }] }
  })
  const ui = await $.ui.mount(PANE)
  expect(await ui.find({ type: 'Text', text: /^b_new/ })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: /^d_old/ })).toBeTruthy()
  for (const gone of [/^a_launched/, /^c_bad/, /^e_older/, /^f_nojournal/]) expect(await ui.find({ type: 'Text', text: gone })).toBeFalsy()
  await ui.unmount()
})

test('strips terminal escapes from status, journal and agent text', () => {
  const ESC = '\x1b]0;pwned\x07\x1b[2J'
  expect(clean(`a${ESC}b\x9b`)).toBe('a]0;pwned[2Jb')
  expect(stageLine({ track: `t${ESC}`, engine: 'e', stage: 'build', verdict: `SHIP${ESC}` })).not.toMatch(/[\x00-\x1f\x7f-\x9f]/)
  const g = workflowGroups(`{"type":"started","agentId":"z","phase":"P\\u001b[31m","label":"L\\u0007"}`, { z: NOW }, NOW)
  expect(g[0].phase + g[0].agents[0].label).not.toMatch(/[\x00-\x1f\x7f-\x9f]/)
  expect(treeLines([{ ...a('x', 'running'), description: `d${ESC}` }])[0].text).not.toMatch(/[\x00-\x1f\x7f-\x9f]/)
})
