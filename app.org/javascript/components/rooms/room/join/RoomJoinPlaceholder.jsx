// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React from 'react';
import { useTranslation } from 'react-i18next';
import Card from 'react-bootstrap/Card';
import {
  Button, Col, Row, Stack,
} from 'react-bootstrap';
import Placeholder from '../../../shared_components/utilities/Placeholder';
import RoundPlaceholder from '../../../shared_components/utilities/RoundPlaceholder';
import Form from '../../../shared_components/forms/Form';

export default function RoomJoinPlaceholder() {
  const { t } = useTranslation();

  return (
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
      <Card.Footer className="px-5 pb-3 bg-white border-2 text-center">
        <Row className="my-4">
          <Form>
            <Placeholder width={12} size="lg" />
            <Button
              variant="brand"
              className="mt-3 d-block float-end"
              disabled
            >
              {t('room.meeting.join_meeting')}
            </Button>
          </Form>
        </Row>
        <Row>
          <Placeholder width={6} size="md" />
        </Row>
      </Card.Footer>
    </Card>
  );
}
