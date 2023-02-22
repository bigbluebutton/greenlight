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
import { Card, Placeholder } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

export default function RoomCardPlaceHolder() {
  const { t } = useTranslation();

  return (
    <Card id="room-card" border="light">
      <Card.Body>
        <Placeholder as={Card.Title} animation="glow" className="mb-3" bg="placeholder">
          <Placeholder style={{ height: '65px', width: '65px', borderRadius: '10%' }} />
        </Placeholder>
        <Placeholder as={Card.Title} animation="glow" bg="placeholder">
          <Placeholder xs={5} size="sm" />
        </Placeholder>
        <Placeholder as={Card.Text} animation="glow" bg="placeholder">
          <Placeholder xs={4} size="xs" /> <Placeholder xs={6} size="xs" />
          <Placeholder xs={2} size="xs" />
        </Placeholder>
      </Card.Body>
      <Card.Footer className="bg-white">
        <Placeholder.Button variant="brand-outline" className="disabled float-end" animation="glow" bg="placeholder">{t('start')}</Placeholder.Button>
      </Card.Footer>
    </Card>
  );
}
