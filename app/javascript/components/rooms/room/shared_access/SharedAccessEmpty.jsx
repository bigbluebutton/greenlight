import React from 'react';
import { Button, Card } from 'react-bootstrap';
import { UserAddIcon } from '@heroicons/react/outline';
import { useTranslation } from 'react-i18next';
import Modal from '../../../shared_components/modals/Modal';
import SharedAccessForm from './forms/SharedAccessForm';

export default function SharedAccessEmpty() {
  const { t } = useTranslation();

  return (
    <div id="shared-access-empty">
      <Card className="border-0 shadow-sm mt-3 text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <UserAddIcon className="hi-l text-brand d-block mx-auto pt-4" />
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
