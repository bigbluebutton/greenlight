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
import { useTranslation } from 'react-i18next';

import Logo from '../../shared_components/Logo';
import ButtonLink from '../../shared_components/utilities/ButtonLink';

export default function PendingRegistration() {
  const { t } = useTranslation();

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-md-4 mx-auto p-4 border-0 card-shadow text-center">
        <Card.Title className="pb-2 fs-1 text-danger">{ t('user.pending.title') }</Card.Title>
        <span className="mb-3">{ t('user.pending.message') }</span>
        <ButtonLink to="/" variant="brand" className="btn btn-lg m-2">
          {t('return_home')}
        </ButtonLink>
      </Card>
    </div>
  );
}
