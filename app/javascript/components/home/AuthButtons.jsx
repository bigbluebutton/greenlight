import React, { useEffect } from 'react';
import { Form, Stack } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import { useLocation, useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';
import useEnv from '../../hooks/queries/env/useEnv';

export default function AuthButtons() {
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

  if (env?.OPENID_CONNECT) {
    return (
      <Form action="/auth/openid_connect" method="POST" data-turbo="false">
        <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
        <Button variant="brand-outline-color" className="btn m-2" type="submit">{t('authentication.sign_up')}</Button>
        <Button variant="brand" className="btn m-2" type="submit">{t('authentication.sign_in')}</Button>
      </Form>
    );
  }

  return (
    <Stack direction="horizontal">
      { showSignUp()
          && (
            <ButtonLink to={`/signup${search}`} variant="brand-outline-color" className="btn me-2">
              {t('authentication.sign_up')}
            </ButtonLink>
          ) }
      <ButtonLink to="/signin" variant="brand" className="btn">{t('authentication.sign_in')}</ButtonLink>
    </Stack>
  );
}
