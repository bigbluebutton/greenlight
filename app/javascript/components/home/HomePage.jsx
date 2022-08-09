import React from 'react';
import { Form } from 'react-bootstrap';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import Spinner from '../shared_components/utilities/Spinner';
import useEnv from '../../hooks/queries/env/useEnv';

export default function HomePage() {
  const { isLoading, data: env } = useEnv();
  if (isLoading) return <Spinner />;

  return (
    env.OPENID_CONNECT ? (
      <Form action="/auth/openid_connect" method="POST" data-turbo="false">
        <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
        <input variant="brand" className="btn mx-2" type="submit" value="Sign In" />
        <input variant="brand-backward" className="btn" type="submit" value="Sign Up" />
      </Form>

    ) : (
      <>
        <ButtonLink to="/signin" variant="brand" className="mx-2">Sign In</ButtonLink>
        <ButtonLink to="/signup" variant="brand-backward">Sign Up</ButtonLink>
      </>
    )
  );
}
