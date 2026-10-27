// Compiles each module of this folder against the app: Allowed.elm must
// compile, every other module must fail with the error its doc comment
// describes, which shows that the opaque types stop the write.
import { spawnSync } from 'node:child_process'
import { dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const cases = [
  ['Allowed.elm', null],
  ['SkipTheGuard.elm', 'TYPE MISMATCH'],
  ['WritePageDirectly.elm', 'TYPE MISMATCH'],
  ['ForgeTheGuard.elm', 'NAMING ERROR'],
  ['ForgeTheCurrentPage.elm', 'NAMING ERROR'],
]

const cwd = dirname(fileURLToPath(import.meta.url))
let failed = false

for (const [file, expected] of cases) {
  const result = spawnSync(
    'elm',
    ['make', file, '--output=/dev/null', '--report=json'],
    { cwd, encoding: 'utf8' },
  )
  const titles =
    result.status === 0
      ? []
      : JSON.parse(result.stderr).errors.flatMap((error) =>
          error.problems.map((problem) => problem.title),
        )
  const ok =
    expected === null ? result.status === 0 : titles.includes(expected)
  console.log(
    `${ok ? 'ok  ' : 'FAIL'} ${file}: ${expected === null ? 'compiles' : titles.join(', ')}`,
  )
  failed = failed || !ok
}

process.exit(failed ? 1 : 0)
