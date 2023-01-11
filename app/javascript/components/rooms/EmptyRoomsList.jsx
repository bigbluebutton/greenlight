import React from 'react';
import { Button, Card } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Modal from '../shared_components/modals/Modal';
import CreateRoomForm from './room/forms/CreateRoomForm';
import useCreateRoom from '../../hooks/mutations/rooms/useCreateRoom';
import { useAuth } from '../../contexts/auth/AuthProvider';
import UserBoardIcon from './UserBoardIcon';

export default function EmptyRoomsList() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const mutationWrapper = (args) => useCreateRoom({ userId: currentUser.id, ...args });

  return (
    <div id="rooms-list-empty">
      <Card className="border-0 shadow-sm mt-5 text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <UserBoardIcon className="hi-l text-brand d-block mx-auto" />
          </div>
          <Card.Title className="text-brand"> { t('room.rooms_list_is_empty') }</Card.Title>
          <Card.Text>
            { t('room.rooms_list_empty_create_room') }
          </Card.Text>
          <Modal
            modalButton={<Button variant="brand" className="ms-auto me-xxl-1">{ t('room.add_new_room') }</Button>}
            title={t('room.create_new_room')}
            body={<CreateRoomForm mutation={mutationWrapper} userId={currentUser.id} />}
          />
        </Card.Body>
      </Card>
    </div>
  );
}
