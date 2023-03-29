import * as esbuild from 'esbuild';

const relativeUrlRoot = (process.env.RELATIVE_URL_ROOT || '').replace(/\/$/, '');

await esbuild.build({
  entryPoints: ['app/javascript/main.jsx'],
  bundle: true,
  minify: true,
  outdir: 'app/assets/builds',
  loader: {
    '.png': 'dataurl',
    '.svg': 'text',
    '.mp3': 'base64',
  },
  define: {
    'process.env.RELATIVE_URL_ROOT': `"${relativeUrlRoot}"`,
  },
});

console.log('watch build finished');
