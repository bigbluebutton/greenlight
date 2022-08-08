import React from 'react';
import Container from 'react-bootstrap/Container';
import useEnv from '../../hooks/queries/env/useEnv';
import Spinner from './stylings/Spinner';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Footer() {
  const { isLoading, data: env } = useEnv();
  const { data: terms } = useSiteSetting('Terms');
  const { data: privacyPolicy } = useSiteSetting('PrivacyPolicy');

  if (isLoading) return <Spinner />;

  return (
    <Container id="footer" className="fixed-bottom text-center py-2">
      <span className="text-muted">Powered by </span>
      <a href="https://bigbluebutton.org/2018/07/09/greenlight-2-0/" target="_blank" rel="noreferrer">Greenlight</a>
      <span className="text-muted"> {env.VERSION_TAG}</span>
      { terms
        && (
        <>
          <span> | </span>
          <a href={terms} target="_blank" rel="noreferrer">Terms</a>
        </>
        )}
      { privacyPolicy
        && (
        <>
          <span> | </span>
          <a href={privacyPolicy} target="_blank" rel="noreferrer">Privacy Policy</a>
        </>
        )}
    </Container>
  );
}
