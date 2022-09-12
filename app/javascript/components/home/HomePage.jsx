import React, { useEffect } from 'react';
import { Card, Form, Stack } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
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
    [],
  );

  if (isLoading) return <Spinner />;

  return (
    <div className="vertical-center">
      <div className="text-center mb-4">
        <Logo size="large" />
      </div>
      <Card className="col-md-8 mx-auto p-5 border-0 shadow-sm text-center">
        <h1 className="mt-4"> { t('welcome_bbb')} </h1>
        <span className="text-muted mt-4 mb-5 px-xxl-5">
          Greenlight is a simple front-end for your BigBlueButton open-source web
          conferencing server.
          You can create your own rooms to host sessions, or
          join others using a short and convenient link.
        </span>
        <Stack direction="horizontal" className="mx-auto mb-2">
          {
            env.OPENID_CONNECT ? (
              <Form action="/auth/openid_connect" method="POST" data-turbo="false">
                <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
                <input variant="brand-backward" className="btn btn-xlg" type="submit" value="Sign Up" />
                <input variant="brand" className="btn btn-xlg mx-4" type="submit" value="Sign In" />
              </Form>
            ) : (
              <>
                <ButtonLink to="/signup" variant="brand-backward" className="btn btn-xlg">Sign Up</ButtonLink>
                <ButtonLink to="/signin" variant="brand" className="btn btn-xlg mx-4">Sign In</ButtonLink>
              </>
            )
          }
        </Stack>
      </Card>
    </div>
  );
}
