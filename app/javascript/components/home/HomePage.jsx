import React, { useEffect } from 'react';
import { Card, Form, Stack } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Button from 'react-bootstrap/Button';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import Spinner from '../shared_components/utilities/Spinner';
import useEnv from '../../hooks/queries/env/useEnv';
import Logo from '../shared_components/Logo';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function HomePage() {
  const { isLoading, data: env } = useEnv();
  const { t } = useTranslation();
  const currentUser = useAuth();
  const navigate = useNavigate();

  // redirect user to correct page based on signed in status and CreateRoom permission
  useEffect(
    () => {
      if (currentUser.signed_in && currentUser.permissions.CreateRoom === 'true') {
        navigate('/rooms');
      } else if (currentUser.signed_in && currentUser.permissions.CreateRoom === 'false') {
        navigate('/home');
      }
    },
    [currentUser.signed_in],
  );

  if (isLoading) return <Spinner />;

  // TODO - samuel: OPENID signup and signin are both pointing at the same endpoint
  return (
    <div className="vertical-center">
      <div className="text-center mb-4">
        <Logo size="large" />
      </div>
      <Card className="col-md-8 mx-auto p-5 border-0 shadow-sm text-center">
        <h1 className="mt-4"> { t('homepage.welcome_bbb')} </h1>
        <span className="text-muted mt-4 mb-5 px-xxl-5">
          { t('homepage.greenlight_description')}
        </span>
        <Stack direction="horizontal" className="mx-auto mb-2">
          {
            env.OPENID_CONNECT ? (
              <Form action="/auth/openid_connect" method="POST" data-turbo="false">
                <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
                <Button variant="brand-outline-color" className="btn btn-xlg" type="submit">{t('authentication.sign_up')}</Button>
                <Button variant="brand" className="btn btn-xlg ms-4" type="submit">{t('authentication.sign_in')}</Button>
              </Form>
            ) : (
              <>
                <ButtonLink to="/signup" variant="brand-outline-color" className="btn btn-xlg">{t('authentication.sign_up')}</ButtonLink>
                <ButtonLink to="/signin" variant="brand" className="btn btn-xlg ms-4">{t('authentication.sign_in')}</ButtonLink>
              </>
            )
          }
        </Stack>
      </Card>
    </div>
  );
}
