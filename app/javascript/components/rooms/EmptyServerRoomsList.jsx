import React from 'react';
import { Card } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

import UserBoardIcon from './UserBoardIcon';

export default function EmptyServerRoomsList() {
  const { t } = useTranslation();

  return (
    <div id="list-empty">
      <Card className="border-0 text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <UserBoardIcon className="hi-l text-brand d-block mx-auto" />
          </div>
          <Card.Title className="text-brand"> { t('admin.server_rooms.empty_room_list') } </Card.Title>
          <Card.Text>
            { t('admin.server_rooms.empty_room_list_subtext') }
          </Card.Text>
        </Card.Body>
      </Card>
    </div>
  );
}
