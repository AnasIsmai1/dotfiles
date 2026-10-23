import { expect, mock, test } from 'claude-code/testing'
import { bandLine, bar, boardColumns, clean, header, isActive, runLine, usageLine, workflowGroups } from './register'

const a = (id: string, status: string, o: any = {}) => ({ id, status, type: o.type ?? id, description: `job ${id}`, ...o }) as any

const J = [
  '{"type":"launched","agentId":"x"}',
  '{"type":"started","agentId":"d1","phase":"Design","label":"designer"}',
  '{"type":"result","agentId":"d1"}',
  '{"type":"started","agentId":"e1","phase":"Execute","label":"coder A"}',
  '{"type":"started","agentId":"e2","phase":"Execute"}',
  '{"type":"started","agentId":"e3","phase":"Execute","label":"flow 2"}',
  '{"type":"failed","agentId":"e3"}',
  '{not json',
  '42',
  '{"type":"result","agentId":"nope"}',
].join('\n')
const NOW = 1_000_000
const run = (m: Record<string, number>, name = 'qa-run') => ({ id: 'wf_1', name, groups: workflowGroups(J, m, NOW) })

test('workflowGroups: phases, done/failed/running/stale, junk skipped', () => {
  expect(workflowGroups(J, { e1: NOW - 1000, e2: NOW - 600001 }, NOW)).toEqual([
    { phase: 'Design', agents: [{ label: 'designer', state: 'done' }] },
    { phase: 'Execute', agents: [{ label: 'coder A', state: 'running' }, { label: 'e2', state: 'stale' }, { label: 'flow 2', state: 'failed' }] },
  ])
  expect(workflowGroups('', {}, NOW)).toEqual([])
})

test('stale boundary is inclusive at 600000 ms', () => {
  const st = (age: number) => workflowGroups(J, { e1: NOW - age }, NOW)[1].agents[0].state
  expect([st(600000), st(600001)]).toEqual(['running', 'stale'])
})

test('bar fills by fraction', () => {
  expect(bar(0, 6)).toBe('▱▱▱▱▱▱')
  expect(bar(4, 6)).toBe('▰▰▰▰▱▱')
  expect(bar(9, 6)).toBe('▰▰▰▰▰▰')
  expect(bar(1, 0)).toBe('▱▱▱▱▱▱')
})

test('header shows track, engine, round and verdict', () => {
  expect(header(null)).toBeNull()
  expect(header({ track: 'fix', engine: 'team', stage: 'test', round: 2 })).toBe('ship · fix/team · round 2')
  expect(header({ track: 'fix', engine: 'team', stage: 'done', verdict: 'SHIP' })).toBe('ship · fix/team · round 1 · SHIP')
})

test('board: stage marks, roles in their columns, children under parents, repeats folded', () => {
  const agents = [
    a('p', 'completed', { teammateId: 'planner@t' }),
    a('c', 'completed', { teammateId: 'coder@t' }),
    a('x', 'completed', { type: 'Explore', parentId: 'c' }),
    a('t', 'running', { teammateId: 'tester@t' }),
    a('d1', 'completed', { type: 'dave' }), a('d2', 'running', { type: 'dave' }),
  ]
  const cols = boardColumns({ stage: 'test' }, agents)
  expect(cols.map(c => `${c.stage}:${c.mark}`)).toEqual(['spec:done', 'build:done', 'test:current', 'review:todo', 'verify:todo'])
  expect(cols[0].cards.map(k => k.text)).toEqual(['planner ✓'])
  expect(cols[1].cards.map(k => k.text)).toEqual(['coder ✓', 'Explore ✓'])
  expect(cols[2].cards).toEqual([{ text: 'tester ●', state: 'running' }])
  expect(cols[4].cards).toEqual([{ text: 'dave ×2 ●', state: 'running' }])
  expect(boardColumns({ stage: 'done' }, []).every(c => c.mark === 'done')).toBe(true)
})

test('runLine: name, progress, counts', () => {
  expect(runLine(run({ e1: NOW }))).toBe('qa-run  ▰▰▰▱▱▱  2/4 agents   1 running · 1 failed')
})

test('usageLine leads with limits', () => {
  const u = { context: { percent: 41.6 }, cost: { usd: 1.5 }, rateLimits: [{ kind: 'five_hour', percentUsed: 10 }, { kind: 'seven_day', percentUsed: 20 }] } as any
  expect(usageLine(u)).toBe('5h 10%  7d 20%  ctx 42%  $1.50')
  expect(usageLine(null)).toBeNull()
})

test('band: compact line only while active', () => {
  expect(bandLine({ stage: 'done' }, [a('x', 'running')], [run({})])).toBeNull()
  expect(bandLine({ track: 'fix', engine: 'team', stage: 'test' }, [a('x', 'running')], [])).toBe('ship fix/team  ▰▰▱▱▱  test · 1 running')
  expect(bandLine(null, [], [run({ e1: NOW })])).toBe('qa-run  ▰▰▰▱▱▱ · 1 running')
  expect(isActive(null, [run({})])).toBe(false)
})

test('strips terminal escapes everywhere text is drawn', () => {
  const ESC = '\x1b]0;pwned\x07\x1b[2J'
  const ctl = /[\x00-\x1f\x7f-\x9f]/
  expect(clean(`a${ESC}b\x9b`)).toBe('a]0;pwned[2Jb')
  expect(header({ track: `t${ESC}`, engine: 'e', stage: 'build', verdict: `SHIP${ESC}` })).not.toMatch(ctl)
  const g = workflowGroups(`{"type":"started","agentId":"z","phase":"P\\u001b[31m","label":"L\\u0007"}`, { z: NOW }, NOW)
  expect(g[0].phase + g[0].agents[0].label).not.toMatch(ctl)
  expect(boardColumns({ stage: 'spec' }, [a('q', 'running', { type: `evil${ESC}` })])[0].cards[0].text).not.toMatch(ctl)
})

const PANE = {
  plugin: 'agent-dash', component: 'Pane', requestId: 'agent-dash', surface: 'terminal',
  props: { title: 'Dash', isFocused: false, bodyColumns: 80, placement: 'dock', scroll: { offset: 0, bodyRows: 40 }, view: {} },
} as const
const BAND = {
  plugin: 'agent-dash', component: 'AbovePrompt', surface: 'terminal',
  props: { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 80, scroll: { offset: 0, bodyRows: 10 }, view: {} },
} as any
const S = '/h/.claude/projects/-p/sid'
const W = `${S}/subagents/workflows`

function world(on: any, status: any, dirs: Record<string, number | null> = { wf_1: NOW }, journals: Record<string, string> = {}, agents: any[] = [a('t', 'running', { teammateId: 'tester@t' })]) {
  mock.env(on, { HOME: '/h' })
  mock.clock(on, { now: NOW })
  on('session.id', () => ({ value: 'sid' }))
  on('session.cwd', () => ({ value: '/p' }))
  on('fs.read', (_: any, e: any) => {
    if (e.path.endsWith('status.json')) { if (status == null) throw new Error('ENOENT'); return { value: JSON.stringify(status) } }
    const id = e.path.split('/').slice(-2)[0]
    if (journals[id] === 'THROW') throw new Error('too big')
    return { value: journals[id] ?? J }
  })
  on('fs.list', (_: any, e: any) => {
    if (e.path === W) { if (dirs == null) throw new Error('ENOENT'); return { value: Object.keys(dirs).map(name => ({ name, kind: 'dir', size: 0, mtimeMs: 0, isLink: false })) } }
    if (e.path === `${S}/workflows/scripts`) return { value: Object.keys(dirs ?? {}).map(id => ({ name: `qa-run-${id}.js`, kind: 'file', size: 1, mtimeMs: 0, isLink: false })) }
    const m = dirs?.[e.path.split('/').pop()]
    return { value: m == null ? [] : [
      { name: 'journal.jsonl', kind: 'file', size: 1, mtimeMs: m, isLink: false },
      { name: 'agent-e1.jsonl', kind: 'file', size: 1, mtimeMs: NOW - 1000, isLink: false },
    ] }
  })
  on('agent.list', () => ({ value: agents }))
  on('session.usage', () => ({ value: { startedAt: 0, context: { window: 1, percent: 12 }, rateLimits: [{ kind: 'five_hour', percentUsed: 23 }] } }))
}

test('pane: header, board columns, workflow line with readable name', async ($, on) => {
  world(on, { track: 'fix', engine: 'team', stage: 'test', round: 2 })
  const ui = await $.ui.mount(PANE)
  expect(await ui.find({ type: 'Text', text: 'ship · fix/team · round 2' })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: '5h 23%  ctx 12%' })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: 'TEST ●' })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: 'tester ●' })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: /qa-run  ▰▰▰▱▱▱  2\/4 agents/ })).toBeTruthy()
  expect(await ui.find({ type: 'Text', text: '  ✗ flow 2' })).toBeTruthy()
  await ui.unmount()
})

test('pane: newest 2 non-empty runs; skips empty, unreadable and journal-less runs', async ($, on) => {
  world(on, null, { a_launched: NOW, b_new: NOW - 1000, c_bad: NOW - 2000, d_old: NOW - 3000, e_older: NOW - 4000, f_nojournal: null },
    { a_launched: '{"type":"launched"}', c_bad: 'THROW' }, [])
  const ui = await $.ui.mount(PANE)
  const lines = (await ui.findAll({ type: 'Text', text: /agents/ })).map((t: any) => t.text).join('\n')
  expect((lines.match(/qa-run/g) ?? []).length).toBe(2)
  await ui.unmount()
})

test('pane: idle shows one quiet line', async ($, on) => {
  world(on, null, null as any, {}, [])
  const ui = await $.ui.mount(PANE)
  expect((await ui.find({ type: 'Text' }))?.text).toBe('no active runs   5h 23%  ctx 12%')
  await ui.unmount()
})

test('band falls through when idle or surveying', async ($, on) => {
  world(on, { stage: 'done' }, null as any)
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
  status = { stage: 'done' }; await clock.advance(1500)
  expect(opens).toBe(1)
  status = { stage: 'test' }; await clock.advance(1500)
  expect(opens).toBe(2)
})
