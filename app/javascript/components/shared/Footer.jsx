import React from 'react';
import Container from 'react-bootstrap/Container';
import useEnv from '../../hooks/queries/env/useEnv';
import Spinner from './stylings/Spinner';

export default function Footer() {
  const { isLoading, data: env } = useEnv();

  if (isLoading) return <Spinner />;

  return (
    <Container id="footer" className="text-center">
      <span className="text-muted">Powered by </span>
      <a href="https://bigbluebutton.org/2018/07/09/greenlight-2-0/" target="_blank" rel="noreferrer">Greenlight.
      </a><span className="text-muted"> {env.VERSION_TAG}</span>
    </Container>
  );
}
