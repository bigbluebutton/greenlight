import React from 'react';
import { Button, Form } from 'react-bootstrap';
import Card from 'react-bootstrap/Card';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import Logo from '../../../shared_components/Logo';
import useEnv from '../../../../hooks/queries/env/useEnv';
import Spinner from '../../../shared_components/utilities/Spinner';
import ButtonLink from '../../../shared_components/utilities/ButtonLink';

export default function RequireAuthentication({ path }) {
  const { t } = useTranslation();
  const { isLoading, data: env } = useEnv();
  if (isLoading) return <Spinner />;

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-6 mx-auto p-0 border-0 shadow-sm text-center">
        <Card.Body className="pt-4 px-5">
          <p className="mb-0">{ t('room.settings.require_signed_in_message') }</p>
        </Card.Body>
        <Card.Footer className="bg-white">
          {
            env.OPENID_CONNECT ? (
              <Form action="/auth/openid_connect" method="POST" data-turbo="false">
                <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
                <Button variant="brand-outline-color" className="btn btn-lg m-2" type="submit">{t('authentication.sign_up')}</Button>
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
