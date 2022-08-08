import React from 'react';
import { Button, Card } from 'react-bootstrap';
import { UserAddIcon } from '@heroicons/react/outline';
import Modal from '../shared_components/Modal';
import SharedAccessForm from '../forms/SharedAccessForm';

export default function SharedAccessEmpty() {
  return (
    <div id="shared-access-empty" className="wide-background full-height-room">
      <Card className="border-0 shadow-sm mt-3 text-center">
        <Card.Body className="py-5">
          <div className="icon-circle rounded-circle d-block mx-auto mb-3">
            <UserAddIcon className="hi-l text-brand d-block mx-auto pt-4" />
          </div>
          <Card.Title className="text-brand"> Time to add some users! </Card.Title>
          <Card.Text>
            To add new users, click the button below and search or select
            the users you want to share this room with.
          </Card.Text>
          <Modal
            modalButton={<Button variant="brand-backward">+ Share Access</Button>}
            title="Share Room Access"
            body={<SharedAccessForm />}
            size="lg"
            id="shared-access-modal"
          />
        </Card.Body>
      </Card>
    </div>
  );
}
