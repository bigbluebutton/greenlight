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

import React, { useEffect } from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import useVerifyToken from '../../../hooks/mutations/users/useVerifyToken';
import ResetPwdForm from './forms/ResetPwdForm';
import Logo from '../../shared_components/Logo';

export default function ResetPassword() {
  const { token } = useParams();
  const verifyTokenAPI = useVerifyToken(token);

  useEffect(() => {
    verifyTokenAPI.mutate();
  }, []);

  if (verifyTokenAPI.isIdle || verifyTokenAPI.isLoading) return null;

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-xl-3 col-lg-4 col-md-6 col-8 mx-auto p-4 border-0 card-shadow">
        <ResetPwdForm token={token} />
      </Card>
    </div>
  );
}
