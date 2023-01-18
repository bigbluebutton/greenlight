import React, { useEffect } from 'react';
import {
  Col, Row,
} from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ArrowRightIcon } from '@heroicons/react/24/outline';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function HomePage() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const navigate = useNavigate();

  // Redirects the user to the proper page based on signed in status and CreateRoom permission
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

  return (
    <>
      <Row className="wide-white">
        <Col lg={8}>
          <div id="homepage-hero">
            <h1 className="my-4"> {t('homepage.welcome_bbb')} </h1>
            <p className="text-muted fs-5">
              {t('homepage.greenlight_description')}
            </p>
            <a href="https://bigbluebutton.org/" className="pt-5 fs-5 text-link fw-bolder">
              {t('homepage.learn_more')}
              <ArrowRightIcon className="hi-s ms-2" />
            </a>
          </div>
        </Col>
      </Row>
      <Row>
        <Col>
        </Col>
        <Col>
        </Col>
        <Col>
        </Col>
        <Col>
        </Col>
      </Row>
    </>
  );
}
