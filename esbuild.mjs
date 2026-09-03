import * as esbuild from 'esbuild';

// Fetch 'RELATIVE_URL_ROOT' ENV variable value while removing any trailing slashes.
const relativeUrlRoot = (process.env.RELATIVE_URL_ROOT || '').replace(/\/*$/, '');
// Determine whether LDAP is used (OIDC takes precedence)
const useLDAP = (process.env.LDAP_SERVER && !process.env.OPENID_CONNECT_ISSUER);

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
    'process.env.OMNIAUTH_PATH': useLDAP ? `"${relativeUrlRoot}/auth/ldap"` : `"${relativeUrlRoot}/auth/openid_connect"`,
  },
});

console.log('watch build finished');
