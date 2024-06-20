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
import { Button, Card } from 'react-bootstrap';
import { UserPlusIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import Modal from '../../../shared_components/modals/Modal';
import SharedAccessForm from './forms/SharedAccessForm';

export default function SharedAccessEmpty() {
  const { t } = useTranslation();

  return (
    <div id="shared-access-empty" className="pt-3">
      <Card className="border-0 card-shadow text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <UserPlusIcon className="hi-l text-brand d-block mx-auto pt-4" />
          </div>
          <Card.Title className="text-brand"> { t('room.shared_access.add_some_users') }</Card.Title>
          <Card.Text>
            { t('room.shared_access.add_some_users_description') }
          </Card.Text>
          <Modal
            modalButton={<Button variant="brand-outline">{ t('room.shared_access.add_share_access') }</Button>}
            title={t('room.shared_access.share_room_access')}
            body={<SharedAccessForm />}
            size="lg"
            id="shared-access-modal"
          />
        </Card.Body>
      </Card>
    </div>
  );
}
