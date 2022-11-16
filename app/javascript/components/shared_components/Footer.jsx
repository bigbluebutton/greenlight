import React from 'react';
import { useTranslation } from 'react-i18next';
import useEnv from '../../hooks/queries/env/useEnv';
import Spinner from './utilities/Spinner';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Footer() {
  const { t } = useTranslation();
  const { isLoading, data: env } = useEnv();
  const { data: terms } = useSiteSetting('Terms');
  const { data: privacyPolicy } = useSiteSetting('PrivacyPolicy');

  if (isLoading) return null;

  return (
    <footer id="footer" className="footer background-whitesmoke text-center pb-2">
      <a href="https://docs.bigbluebutton.org/greenlight_v3/gl3-install.html" target="_blank" rel="noreferrer">Greenlight</a>
      <span className="text-muted"> {env.VERSION_TAG} </span>
      { terms
        && (
          <a className="ps-3" href={terms} target="_blank" rel="noreferrer">{ t('admin.site_settings.administration.terms') }</a>
        )}
      { privacyPolicy
        && (
          <a className="ps-3" href={privacyPolicy} target="_blank" rel="noreferrer">{ t('admin.site_settings.administration.privacy_policy') }</a>
        )}
    </footer>
  );
}
