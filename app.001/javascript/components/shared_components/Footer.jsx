import React from 'react';
import { useTranslation } from 'react-i18next';
import { Container } from 'react-bootstrap';
import useEnv from '../../hooks/queries/env/useEnv';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Footer() {
  const { t } = useTranslation();
  const { data: env } = useEnv();
  const { data: links } = useSiteSetting(['Terms', 'PrivacyPolicy']);

  return (
    <footer id="footer" className="footer background-whitesmoke text-center">
      <Container id="footer-container" className="py-3">
        <a href="https://sabura.live" target="_blank" rel="noreferrer"><p>&copy; 2024 {t('site_copyright')}</p></a>
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
      </Container>
    </footer>
  );
}
