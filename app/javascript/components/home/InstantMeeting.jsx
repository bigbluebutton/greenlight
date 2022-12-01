import React from 'react';
import Image from 'react-bootstrap/Image';
import {Col, Row, Stack} from 'react-bootstrap';
import { Link, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import InstantMeetingForm from './InstantMeetingForm';
import Logo from '../shared_components/Logo';

export default function InstantMeeting() {
  const { t } = useTranslation();
  const location = useLocation();
  const path = encodeURIComponent(location.pathname);

  return (
    <div id="instant-meeting">
      <Row>
        <Col colSpan={6}>
          <div className="p-4">
            <Stack id="homepage-header" direction="horizontal" className="w-100">
              <Logo />
              {/* TODO this should be its own component */}
              <div className="ms-auto text-muted"> {t('authentication.already_have_account')}
                <Link to={`/signin?location=${path}`} className="text-link ms-1"> {t('authentication.sign_in')} </Link>
              </div>
            </Stack>

            <div id="instant-meeting-banner" className="position-absolute bottom-0">
              <h3 className="mb-3"> BLINDSIDE NETWORKS </h3>
              <span className="header-title fw-bold my-3"> Start & join meetings now!</span>
              <p className="mt-3"> No account necessary </p>
              <InstantMeetingForm />
            </div>
          </div>
        </Col>
        <Col colSpan={6}>
          {/* TODO host image on our aws or find solution to serve image w/ react */}
          <Image src="https://i.postimg.cc/HxhbYRWk/banner-2.jpg" className="w-100 vh-100" />
        </Col>
      </Row>
    </div>
  );
}
