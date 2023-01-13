import React from 'react';
import { useTranslation } from 'react-i18next';
import useEnv from '../../hooks/queries/env/useEnv';
import useSiteSettings from '../../hooks/queries/admin/site_settings/useSiteSettings';

export default function Footer() {
  const { t } = useTranslation();
  const { data: env } = useEnv();
  const { data: links } = useSiteSettings(['Terms', 'PrivacyPolicy']);

  return (
    <footer id="footer" className="footer background-whitesmoke text-center pb-2">
      <a href="https://docs.bigbluebutton.org/greenlight_v3/gl3-install.html" target="_blank" rel="noreferrer">Greenlight</a>
      <span className="text-muted"> {env?.VERSION_TAG} </span>
      { links?.Terms
        && (
          <a className="ps-3" href={links?.Terms} target="_blank" rel="noreferrer">
            { t('admin.site_settings.administration.terms') }
          </a>
        )}
      { links?.PrivacyPolicy
        && (
          <a className="ps-3" href={links?.PrivacyPolicy} target="_blank" rel="noreferrer">
            { t('admin.site_settings.administration.privacy_policy') }
          </a>
        )}
    </footer>
  );
}
