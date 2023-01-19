import React, { useEffect } from 'react';
import {
  Col, Row,
} from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  ArrowRightIcon, Cog8ToothIcon, ComputerDesktopIcon, VideoCameraIcon, WrenchScrewdriverIcon,
} from '@heroicons/react/24/outline';
import { useAuth } from '../../contexts/auth/AuthProvider';
import HomepageFeatureCard from './HomepageFeatureCard';

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
        <Col lg={10}>
          <div id="homepage-hero">
            <h1 className="my-4"> {t('homepage.welcome_bbb')} </h1>
            <p className="text-muted fs-5">
              {t('homepage.bigbluebutton_description')}
            </p>
            <p className="text-muted fs-5">
              {t('homepage.greenlight_description')}
            </p>
            <a href="https://bigbluebutton.org/" className="fs-5 text-link fw-bolder">
              {t('homepage.learn_more')}
              <ArrowRightIcon className="hi-s ms-2" />
            </a>
          </div>
        </Col>
      </Row>
      <Row>
        <h4 className="text-muted text-uppercase my-4 py-1">{t('homepage.explore_features')}</h4>
        <Col className="mb-3">
          <HomepageFeatureCard
            title={t('homepage.meeting_title')}
            description={t('homepage.meeting_description')}
            icon={<ComputerDesktopIcon className="hi-s text-white" />}
          />
        </Col>
        <Col className="mb-3">
          <HomepageFeatureCard
            title={t('homepage.recording_title')}
            description={t('homepage.recording_description')}
            icon={<VideoCameraIcon className="hi-s text-white" />}
          />
        </Col>
        <Col className="mb-3">
          <HomepageFeatureCard
            title={t('homepage.settings_title')}
            description={t('homepage.settings_description')}
            icon={<Cog8ToothIcon className="hi-s text-white" />}
          />
        </Col>
        <Col className="mb-3">
          <HomepageFeatureCard
            title={t('homepage.and_more_title')}
            description={t('homepage.and_more_description')}
            icon={<WrenchScrewdriverIcon className="hi-s text-white" />}
          />
        </Col>
      </Row>
    </>
  );
}
