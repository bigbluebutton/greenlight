import React, { useEffect } from 'react';
import {
  Col, Row, Form, Stack, Container
} from 'react-bootstrap';
import { useLocation, useNavigate, useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Button from 'react-bootstrap/Button';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import useEnv from '../../hooks/queries/env/useEnv';
import Logo from '../shared_components/Logo';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';
import { useAuth } from '../../contexts/auth/AuthProvider';

import Image from '../../../assets/images/setting.png';

export default function HomePage() {
  const { data: env } = useEnv();
  const { t } = useTranslation();
  const { search } = useLocation();
  const currentUser = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const inviteToken = searchParams.get('inviteToken');
  const { data: registrationMethod } = useSiteSetting('RegistrationMethod');

  useEffect(() => {
    document.cookie = `inviteToken=${inviteToken};path=/;`;
  }, [inviteToken]);

  // redirect user to correct page based on signed in status and CreateRoom permission
  useEffect(
    () => {
      if (!currentUser.stateChanging && currentUser.signed_in && currentUser.permissions.CreateRoom === 'true') {
        navigate('/rooms');
      } else if (!currentUser.stateChanging && currentUser.signed_in && currentUser.permissions.CreateRoom === 'false') {
        navigate('/home');
      }
    },
    [currentUser.signed_in],
  );

  function showSignUp() {
    return registrationMethod !== 'invite' || !!inviteToken;
  }

  // TODO - samuel: OPENID signup and signin are both pointing at the same endpoint
  return (
    <>
      <Row className="bg-white">
        <Col className="col-lg-6 mx-auto">
          <div className="text-center pt-xl-5 my-3">
            <Logo size="medium" />
          </div>
          <div className="text-center">
            <h1 className="my-4"> {t('homepage.welcome_bbb')} </h1>
            <p className="text-muted fs-5">
              {t('homepage.greenlight_description')}
            </p>
            <a href="https://bigbluebutton.org/" className="pt-5 fs-5 text-link"> Learn more about BigBlueButton. </a>
          </div>
          <div className="text-center my-5">
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
        </Col>
      </Row>

      <Container className="pt-xl-3">
        <Row>
          <Col>
            <Stack className="text-center my-5 homepage-icon d-block mx-auto">
              <div className="mb-3">
                <img src={Image} />
              </div>
              <h4> Launch a meeting </h4>
              <span> Launch a virtual class that maximizes applied learning. </span>
            </Stack>
          </Col>
          <Col>
            <Stack className="text-center my-5 homepage-icon d-block mx-auto">
              <div className="mb-3">
                <img src="https://i.ibb.co/Gk1mPKv/webcam.png" />
              </div>
              <h4> Record your meetings </h4>
              <span> BigBlueButton meetings can be recorded and shared to the students. </span>
            </Stack>
          </Col>
          <Col>
            <Stack className="text-center my-5 homepage-icon d-block mx-auto">
              <div className="mb-3">
                <img src="https://i.ibb.co/T82M2jY/setting.png" />
              </div>
              <h4> Manage your rooms </h4>
              <span> Configure a room to help you run effective virtual classes. </span>
            </Stack>
          </Col>
          <Col>
            <Stack className="text-center my-5 homepage-icon d-block mx-auto">
              <div className="mb-3">
                <img src="https://i.ibb.co/3p7shD1/paint-brush.png" />
              </div>
              <h4> And more! </h4>
              <span> BigBlueButton gives you built-in tools to improve the online learning & teaching experience. </span>
              <br />
            </Stack>
          </Col>
        </Row>
      </Container>
    </>
  );
}
