import * as esbuild from 'esbuild';

// Fetch 'RELATIVE_URL_ROOT' ENV variable value while removing any trailing slashes.
const relativeUrlRoot = (process.env.RELATIVE_URL_ROOT || '').replace(/\/*$/, '');
const serverTagNames = (process.env.SERVER_TAG_NAMES || '');

esbuild.context({
  entryPoints: ['app/javascript/main.jsx'],
  bundle: true,
  sourcemap: true,
  outdir: 'app/assets/builds',
  loader: {
    '.png': 'dataurl',
    '.svg': 'text',
  },
  define: {
    'process.env.RELATIVE_URL_ROOT': `"${relativeUrlRoot}"`,
    'process.env.OMNIAUTH_PATH': `"${relativeUrlRoot}/auth/openid_connect"`, // currently, only OIDC is implemented
    'process.env.SERVER_TAG_NAMES': `"${serverTagNames}"`,
  },
}).then(context => {
  if (process.argv.includes("--watch")) {
    // Enable watch mode
    context.watch()
  } else {
    // Build once and exit if not in watch mode
    context.rebuild().then(result => {
      context.dispose()
    })
  }
  console.log('build succeeded');
}).catch((e) => {
  console.error('build failed:', e);
  process.exit(1)
})
