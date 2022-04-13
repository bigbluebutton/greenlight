import React from 'react';
import Card from 'react-bootstrap/Card';
import { Link } from 'react-router-dom';
import SigninForm from '../forms/SigninForm';
import FormLogo from '../forms/FormLogo';

export default function SignIn() {
  return (
    <>
      <FormLogo />
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> Login </Card.Title>
        <SigninForm />
        <span className="text-center text-muted small"> Don&apos;t have an account?
          <Link to="/signup" className="text-link"> Sign up </Link>
        </span>
      </Card>
    </>
  );
}
