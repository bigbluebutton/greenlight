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
        <hr />
        <Placeholder.Button variant="brand-outline" className="disabled float-end" animation="glow" bg="placeholder">{t('start')}</Placeholder.Button>
      </Card.Body>
    </Card>
  );
}
