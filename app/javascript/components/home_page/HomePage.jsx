import React from 'react';
import { Form } from 'react-bootstrap';
import ButtonLink from '../shared/stylings/buttons/ButtonLink';

export default function HomePage() {
  return (
    <>
      <ButtonLink to="/signin" className="mx-2">Sign In</ButtonLink>
      <ButtonLink to="/signup" variant="outline-primary">Sign Up</ButtonLink>
      <Form action="/auth/openid_connect" method="POST" data-turbo="false">
        <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
        <input type="submit" value="Submit" />
      </Form>
    </>
  );
}
