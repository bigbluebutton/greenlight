import React from 'react';
import { useTranslation } from 'react-i18next';
import Card from 'react-bootstrap/Card';
import {
  Button, Col, Row, Stack,
} from 'react-bootstrap';
import Logo from '../../../shared_components/Logo';
import Placeholder from '../../../shared_components/utilities/Placeholder';
import RoundPlaceholder from '../../../shared_components/utilities/RoundPlaceholder';

export default function RoomJoinPlaceholder() {
  const { t } = useTranslation();

  return (
    <div className="vertical-buffer">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-md-6 mx-auto p-0 border-0 card-shadow">
        <Card.Body className="pt-4 px-5">
          <Row>
            <Col className="col-xxl-8">
              <Placeholder width={6} size="md" className="mt-1" />
              <Placeholder width={12} size="lg" />
            </Col>
            <Col>
              <Stack direction="vertical" gap={3}>
                <RoundPlaceholder size="medium" className="d-block mx-auto" />
                <Placeholder width={10} size="md" className="d-block mx-auto" />
              </Stack>
            </Col>
          </Row>
        </Card.Body>
        <Card.Footer className="px-5 pb-3 bg-white border-2">
          <div className="mt-4">
            <Placeholder width={12} size="lg" />
            <Button
              variant="brand"
              className="mt-3 d-block float-end"
              disabled
            >
              {t('room.meeting.join_meeting')}
            </Button>
          </div>
        </Card.Footer>
      </Card>
    </div>
  );
}
