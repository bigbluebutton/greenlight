import React from 'react';
import SignupForm from '../forms/SignupForm';
import SignFormWrapper from '../forms/SignFormWrapper';
import { signupForm } from '../../helpers/forms/SignupFormHelpers';

export default function Signup() {
  const form = signupForm;
  return (
    <SignFormWrapper form={form}>
      <SignupForm />
    </SignFormWrapper>
  );
}
