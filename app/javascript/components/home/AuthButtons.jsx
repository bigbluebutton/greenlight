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
import { Form, Stack } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import { useLocation, useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';
import useEnv from '../../hooks/queries/env/useEnv';

export default function AuthButtons({ direction }) {
  const { data: env } = useEnv();
  const { t } = useTranslation();
  const { search } = useLocation();
  const { data: registrationMethod } = useSiteSetting('RegistrationMethod');
  const [searchParams] = useSearchParams();
  const inviteToken = searchParams.get('inviteToken');

  useEffect(() => {
    document.cookie = `inviteToken=${inviteToken};path=/;`;
  }, [inviteToken]);

  function showSignUp() {
    return registrationMethod !== 'invite' || !!inviteToken;
  }

  if (env?.EXTERNAL_AUTH) {
    return (
      <Form action={process.env.OMNIAUTH_PATH} method="POST" data-turbo="false">
        <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
        <input type="hidden" name="current_provider" value={env?.CURRENT_PROVIDER} />
        <Stack direction={direction} gap={2}>
          <Button variant="brand-outline-color" className="btn" type="submit">{t('authentication.sign_up')}</Button>
          <Button variant="brand" className="btn" type="submit">{t('authentication.sign_in')}</Button>
        </Stack>
      </Form>
    );
  }

  return (
    <Stack direction={direction} gap={2}>
      { showSignUp()
          && (
            <ButtonLink to={`/signup${search}`} variant="brand-outline-color" className="btn">
              {t('authentication.sign_up')}
            </ButtonLink>
          ) }
      <ButtonLink to="/signin" variant="brand" className="btn">{t('authentication.sign_in')}</ButtonLink>
    </Stack>
  );
}

AuthButtons.defaultProps = {
  direction: 'horizontal',
};

AuthButtons.propTypes = {
  direction: PropTypes.oneOf(['horizontal', 'vertical']),
};
