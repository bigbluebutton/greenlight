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
import Card from 'react-bootstrap/Card';
import { Link, Navigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import ForgetPwdForm from './forms/ForgetPwdForm';
import Logo from '../../shared_components/Logo';
import useEnv from '../../../hooks/queries/env/useEnv';

export default function ForgetPassword() {
  const { t } = useTranslation();
  const { data: env, isLoading } = useEnv();

  if (isLoading) return null;

  if (!env?.SMTP_ENABLED) {
    return <Navigate to="/" />;
  }

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-xl-4 col-lg-6 col-md-8 col-10 mx-auto p-4 border-0 card-shadow">
        <Card.Title className="text-center pb-2"> { t('user.account.reset_password')} </Card.Title>
        <ForgetPwdForm />
        <span className="text-center text-muted small"> { t('or') }
          <Link to="/signin" className="text-link"> { t('authentication.sign_in') } </Link>
        </span>
      </Card>
    </div>
  );
}
