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
import { Button, Form } from 'react-bootstrap';
import Card from 'react-bootstrap/Card';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import Logo from '../../../shared_components/Logo';
import useEnv from '../../../../hooks/queries/env/useEnv';
import ButtonLink from '../../../shared_components/utilities/ButtonLink';

export default function RequireAuthentication({ path }) {
  const { t } = useTranslation();
  const { data: env } = useEnv();

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-xl-6 col-lg-7 col-md-9 col-10 mx-auto p-0 border-0 card-shadow text-center">
        <Card.Body className="pt-4 px-5">
          <p className="mb-0">{ t('room.settings.require_signed_in_message') }</p>
        </Card.Body>
        <Card.Footer className="bg-white">
          {
            env?.OPENID_CONNECT ? (
              <Form action={process.env.OMNIAUTH_PATH} method="POST" data-turbo="false">
                <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
                <Button variant="brand" className="btn btn-lg m-2" type="submit">{t('authentication.sign_in')}</Button>
              </Form>
            ) : (
              <>
                <ButtonLink to={`/signup?location=${path}`} variant="brand-outline-color" className="btn btn-lg m-2">
                  {t('authentication.sign_up')}
                </ButtonLink>
                <ButtonLink to={`/signin?location=${path}`} variant="brand" className="btn btn-lg m-2">{t('authentication.sign_in')}</ButtonLink>
              </>
            )
          }
        </Card.Footer>
      </Card>
    </div>
  );
}

RequireAuthentication.propTypes = {
  path: PropTypes.string.isRequired,
};
