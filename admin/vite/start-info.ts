
import boxen from 'boxen'
import picocolors from 'picocolors'
import pkg from '../package.json'

export default function startInfo(): any {
  return {
    name: 'startInfo',
    apply: 'serve',
    async buildStart() {
      const { bold, cyan, underline } = picocolors

      console.log(
        boxen(
          `${bold(cyan(`FastApp v${pkg.version}`))}\n\n${underline('https://xx/fastapp')}`,
          {
            padding: 1,
            margin: 1,
            borderStyle: 'double',
            title: 'Welcome use',
            titleAlignment: 'center',
            textAlignment: 'center',
          },
        ),
      )
    },
  }
}
