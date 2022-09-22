import React from 'react';
import { Card } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import SignupForm from './forms/SignupForm';
import Logo from '../../shared_components/Logo';

export default function Signup() {
  const { t } = useTranslation();

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> { t('authentication.create_an_account') } </Card.Title>
        <SignupForm />
        <span className="text-center text-muted small"> { t('authentication.already_have_account') }
          <Link to="/signin" className="text-link"> { t('authentication.sign_in') } </Link>
        </span>
      </Card>
    </div>
  );
}
