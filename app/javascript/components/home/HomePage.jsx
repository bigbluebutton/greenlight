import React from 'react';
import { Card, Form, Stack } from 'react-bootstrap';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import Spinner from '../shared_components/utilities/Spinner';
import useEnv from '../../hooks/queries/env/useEnv';
import Logo from '../shared_components/Logo';

export default function HomePage() {
  const { isLoading, data: env } = useEnv();
  if (isLoading) return <Spinner />;

  if (env.OPENID_CONNECT) {
    return (
    // env.OPENID_CONNECT ? (
      <Form action="/auth/openid_connect" method="POST" data-turbo="false">
        <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
        <input variant="brand" className="btn mx-2" type="submit" value="Sign In" />
        <input variant="brand-backward" className="btn" type="submit" value="Sign Up" />
      </Form>
    );
  }

  return (
    <div className="vertical-center">
      <Logo className="d-block mx-auto mb-4 brand-image-lg" />
      <Card className="col-md-8 mx-auto p-4 border-0 shadow-sm text-center">
        <h1 className="mt-4"> Welcome to BigBlueButton. </h1>
        <span className="text-muted mt-4 mb-5 px-xxl-5">
          Greenlight is a simple front-end for your BigBlueButton open-source web
          conferencing server.
          You can create your own rooms to host sessions, or
          join others using a short and convenient link.
        </span>
        <Stack direction="horizontal" className="mx-auto mb-2">
          <ButtonLink to="/signup" variant="brand-backward" className="btn btn-xlg">Sign Up</ButtonLink>
          <ButtonLink to="/signin" variant="brand" className="btn btn-xlg mx-4">Sign In</ButtonLink>
        </Stack>
      </Card>
    </div>
  );
}
