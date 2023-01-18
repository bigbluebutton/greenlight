import React, { useEffect } from 'react';
import {
  Col, Row, Form,
} from 'react-bootstrap';
import { useLocation, useNavigate, useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Button from 'react-bootstrap/Button';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import useEnv from '../../hooks/queries/env/useEnv';
import Logo from '../shared_components/Logo';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';
import { useAuth } from '../../contexts/auth/AuthProvider';

import MeetingIcon from '../../../assets/images/desktop-computer.png';
import RecordingIcon from '../../../assets/images/webcam.png';
import SettingsIcon from '../../../assets/images/setting.png';
import LearningToolsIcon from '../../../assets/images/paint-brush.png';
import HomepageIcon from './HomepageIcon';

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
      // Todo: Use PermissionChecker.
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
      <Row className="wide-white">
        <Col className="mx-auto">
          <div className="text-center pt-xl-5 my-3">
            <Logo />
          </div>
          <div className="text-center">
            <h1 className="my-4"> {t('homepage.welcome_bbb')} </h1>
            <p className="text-muted fs-5 px-xxl-5">
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
      <Row>
        <Col>
          <HomepageIcon title={t('homepage.meeting_title')} description={t('homepage.meeting_description')} icon={MeetingIcon} />
        </Col>
        <Col>
          <HomepageIcon title={t('homepage.recording_title')} description={t('homepage.recording_description')} icon={RecordingIcon} />
        </Col>
        <Col>
          <HomepageIcon title={t('homepage.settings_title')} description={t('homepage.settings_description')} icon={SettingsIcon} />
        </Col>
        <Col>
          <HomepageIcon title={t('homepage.learning_tools_title')} description={t('homepage.learning_tools_description')} icon={LearningToolsIcon} />
        </Col>
      </Row>
    </>
  );
}
