import React from 'react';
import { Card } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import SignupForm from './forms/SignupForm';
import Logo from '../../shared_components/Logo';

export default function Signup() {
  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> Create an Account </Card.Title>
        <SignupForm />
        <span className="text-center text-muted small"> Already have an account?
          <Link to="/signin" className="text-link"> Log in </Link>
        </span>
      </Card>
    </div>
  );
}
