import React from 'react';
import { Form } from 'react-bootstrap';
import ButtonLink from '../shared/stylings/buttons/ButtonLink';
import Spinner from '../shared/stylings/Spinner';
import useEnv from '../../hooks/queries/env/useEnv';

export default function HomePage() {
  const { isLoading, data: env } = useEnv();
  if (isLoading) return <Spinner />;

  return (
    env.OPENID_CONNECT ? (
      <Form action="/auth/openid_connect" method="POST" data-turbo="false">
        <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
        <input className="btn btn-primary mx-2" type="submit" value="Sign In" />
        <input className="btn btn-outline-primary" type="submit" value="Sign Up" />
      </Form>

    ) : (
      <>
        <ButtonLink to="/signin" className="mx-2">Sign In</ButtonLink>
        <ButtonLink to="/signup" variant="outline-primary">Sign Up</ButtonLink>
      </>
    )
  );
}
