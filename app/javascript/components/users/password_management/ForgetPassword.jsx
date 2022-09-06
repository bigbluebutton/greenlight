import React from 'react';
import Card from 'react-bootstrap/Card';
import { Link } from 'react-router-dom';
import ForgetPwdForm from './forms/ForgetPwdForm';
import Logo from '../../shared_components/Logo';

export default function ForgetPassword() {
  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> Reset Password </Card.Title>
        <ForgetPwdForm />
        <span className="text-center text-muted small"> Remembered the password?
          <Link to="/signin" className="text-link"> Login </Link>
        </span>
      </Card>
    </div>
  );
}
