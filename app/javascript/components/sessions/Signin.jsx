import React from 'react';
import SigninForm from '../forms/SigninForm';
import SignFormWrapper from '../forms/SignFormWrapper';

export default function Signin() {
  return (
    <SignFormWrapper title="Sign In" haveAnAccount>
      <SigninForm />
    </SignFormWrapper>
  );
}
