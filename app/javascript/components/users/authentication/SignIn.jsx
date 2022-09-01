import React from 'react';
import Card from 'react-bootstrap/Card';
import { Link } from 'react-router-dom';
import SigninForm from './forms/SigninForm';
import Logo from '../../shared_components/Logo';

export default function SignIn() {
  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo width="300px" />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> Login </Card.Title>
        <SigninForm />
        <span className="text-center text-muted small"> Don&apos;t have an account?
          <Link to="/signup" className="text-link"> Sign up </Link>
        </span>
      </Card>
    </div>
  );
}
