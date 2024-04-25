import * as esbuild from 'esbuild';

// Fetch 'RELATIVE_URL_ROOT' ENV variable value while removing any trailing slashes.
const relativeUrlRoot = (process.env.RELATIVE_URL_ROOT || '').replace(/\/*$/, '');
const serverTagNames = (process.env.SERVER_TAG_NAMES || '');

await esbuild.build({
  entryPoints: ['app/javascript/main.jsx'],
  bundle: true,
  minify: true,
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
});

console.log('watch build finished');
