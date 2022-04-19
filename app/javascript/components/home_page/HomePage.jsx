import React from 'react';
import ButtonLink from '../shared/stylings/buttons/ButtonLink';

export default function HomePage() {
  return (
    <>
      <ButtonLink to="/signin" className="mx-2">Sign In</ButtonLink>
      <ButtonLink to="/signup" variant="outline-primary">Sign Up</ButtonLink>
    </>
  );
}
