import React from 'react';
import Card from 'react-bootstrap/Card';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import ForgetPwdForm from './forms/ForgetPwdForm';
import Logo from '../../shared_components/Logo';

export default function ForgetPassword() {
  const { t } = useTranslation();

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo  />
      </div>
      <Card className="col-xl-3 col-lg-4 col-md-6 col-8 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> { t('user.account.reset_password')} </Card.Title>
        <ForgetPwdForm />
        <span className="text-center text-muted small"> { t('or') }
          <Link to="/signin" className="text-link"> { t('authentication.sign_in') } </Link>
        </span>
      </Card>
    </div>
  );
}
