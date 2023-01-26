import React from 'react';
import Card from 'react-bootstrap/Card';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import SigninForm from './forms/SigninForm';
import Logo from '../../shared_components/Logo';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';

export default function SignIn() {
  const { t } = useTranslation();
  const { data: registrationMethod } = useSiteSetting('RegistrationMethod');

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-xl-3 col-lg-4 col-md-6 col-8 mx-auto p-4 border-0 shadow-sm">
        <Card.Title className="text-center pb-2"> { t('authentication.sign_in') } </Card.Title>
        <SigninForm />
        { registrationMethod !== 'invite' && (
        <span className="text-center text-muted small"> { t('authentication.dont_have_account') }
          <Link to="/signup" className="text-link"> { t('authentication.sign_up') } </Link>
        </span>
        )}
      </Card>
    </div>
  );
}
