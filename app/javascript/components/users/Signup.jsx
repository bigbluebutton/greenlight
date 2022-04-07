import React from 'react';
import SignupForm from '../forms/SignupForm';
import SignFormWrapper from '../forms/SignFormWrapper';

export default function Signup() {
  return (
    <SignFormWrapper title="Create an Account">
      <SignupForm />
    </SignFormWrapper>
  );
}
