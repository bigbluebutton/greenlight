import React from 'react';
import SigninForm from '../forms/SigninForm';
import SignFormWrapper from '../forms/SignFormWrapper';
import { signinForm } from '../../helpers/forms/SigninFormHelpers';

export default function Signin() {
  const form = signinForm;
  return (
    <SignFormWrapper form={form}>
      <SigninForm />
    </SignFormWrapper>
  );
}
