import React, { useEffect } from 'react';
import { Card, Form } from 'react-bootstrap';
import { useLocation, useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Button from 'react-bootstrap/Button';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import useEnv from '../../hooks/queries/env/useEnv';
import Logo from '../shared_components/Logo';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function HomePage() {
  const { data: env } = useEnv();
  const { t } = useTranslation();

  const { search } = useLocation();
  const [searchParams] = useSearchParams();
  const inviteToken = searchParams.get('inviteToken');
  const { data: registrationMethod } = useSiteSetting('RegistrationMethod');

  useEffect(() => {
    document.cookie = `token=${inviteToken};path=/;`;
  }, [inviteToken]);

  function showSignUp() {
    return registrationMethod !== 'invite' || !!inviteToken;
  }

  // TODO - samuel: OPENID signup and signin are both pointing at the same endpoint
  return (
    <div className="vertical-buffer">
      <div className="text-center mb-4">
        <Logo size="large" />
      </div>
      <Card className="col-md-8 mx-auto p-5 border-0 shadow-sm text-center">
        <h1 className="mt-4"> {t('homepage.welcome_bbb')} </h1>
        <span className="text-muted mt-4 mb-5 px-xxl-5">
          {t('homepage.greenlight_description')}
        </span>
        <div className="mx-auto mb-2">
          {
            env?.OPENID_CONNECT ? (
              <Form action="/auth/openid_connect" method="POST" data-turbo="false">
                <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
                <Button variant="brand-outline-color" className="btn btn-xlg m-2" type="submit">{t('authentication.sign_up')}</Button>
                <Button variant="brand" className="btn btn-xlg m-2" type="submit">{t('authentication.sign_in')}</Button>
              </Form>
            ) : (
              <>
                { showSignUp()
                  && (
                  <ButtonLink to={`/signup${search}`} variant="brand-outline-color" className="btn btn-xlg m-2">
                    {t('authentication.sign_up')}
                  </ButtonLink>
                  ) }
                <ButtonLink to="/signin" variant="brand" className="btn btn-xlg m-2">{t('authentication.sign_in')}</ButtonLink>
              </>
            )
          }
        </div>
      </Card>
    </div>
  );
}
