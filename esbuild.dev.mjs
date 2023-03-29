import * as esbuild from 'esbuild';

const relativeUrlRoot = (process.env.RELATIVE_URL_ROOT || '').replace(/\/$/, '');

await esbuild.build({
  entryPoints: ['app/javascript/main.jsx'],
  bundle: true,
  sourcemap: true,
  outdir: 'app/assets/builds',
  loader: {
    '.png': 'dataurl',
    '.svg': 'text',
  },
  watch: {
    onRebuild: (error, result) => {
      if (error) console.error('watch build failed:', error);
      else console.log('watch build succeeded:', result);
    },
  },
  define: {
    'process.env.RELATIVE_URL_ROOT': `"${relativeUrlRoot}"`,
  },
});

console.log('watch build started');
