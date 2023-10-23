// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React from 'react';
import { Card } from 'react-bootstrap';
import { Navigate, Link, useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import SignupForm from './forms/SignupForm';
import Logo from '../../shared_components/Logo';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';
import useEnv from '../../../hooks/queries/env/useEnv';

export default function Signup() {
  const { t } = useTranslation();
  const [searchParams] = useSearchParams();
  const inviteToken = searchParams.get('inviteToken');
  const registrationMethodSettingAPI = useSiteSetting('RegistrationMethod');
  const envAPI = useEnv();
  const isLoading = envAPI.isLoading || registrationMethodSettingAPI.isLoading;

  if (envAPI.data?.OPENID_CONNECT) {
    return <Navigate to="/" replace />;
  }

  if (registrationMethodSettingAPI.data === 'invite' && !inviteToken) {
    toast.error(t('toast.error.users.invalid_invite'));
    return <Navigate to="/" replace />;
  }

  if (isLoading) {
    return null;
  }

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-xl-5 col-lg-6 col-md-8 col-10 mx-auto p-4 border-0 card-shadow">
        <Card.Title className="text-center pb-2"> { t('authentication.create_an_account') } </Card.Title>
        <SignupForm />
        <span className="text-center text-muted small"> { t('authentication.already_have_account') }
          <Link to="/signin" className="text-link"> { t('authentication.sign_in') } </Link>
        </span>
      </Card>
    </div>
  );
}
