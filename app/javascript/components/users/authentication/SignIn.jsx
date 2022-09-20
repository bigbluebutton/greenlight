import React from 'react';
import Card from 'react-bootstrap/Card';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import SigninForm from './forms/SigninForm';
import Logo from '../../shared_components/Logo';

export default function SignIn() {
  const { t } = useTranslation();

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> { t('authentication.sign_in') } </Card.Title>
        <SigninForm />
        <span className="text-center text-muted small"> { t('authentication.dont_have_account') }
          <Link to="/signup" className="text-link"> { t('authentication.sign_up') } </Link>
        </span>
      </Card>
    </div>
  );
}
