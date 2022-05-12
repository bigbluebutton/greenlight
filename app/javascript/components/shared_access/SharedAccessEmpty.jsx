import React from 'react';
import { Button, Card } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faUser } from '@fortawesome/free-regular-svg-icons';
import Modal from '../shared/Modal';
import SharedAccessForm from '../forms/shared_access_forms/SharedAccessForm';

export default function SharedAccessEmpty() {
  return (
    <div id="shared-access-empty" className="wide-background full-height-room">
      <Card className="border-0 shadow-sm mt-5 text-center">
        <Card.Body className="py-5">
          <div className="user-circle d-block mx-auto mb-3">
            <FontAwesomeIcon icon={faUser} className="fa-4x text-primary d-block mx-auto pt-3" />
          </div>
          <Card.Title className="text-primary"> Time to add some users! </Card.Title>
          <Card.Text>
            To add new users, click the button below and search or select
            the users you want to share this room with.
          </Card.Text>
          <Modal
            modalButton={<Button variant="primary-reverse">+ Share Access</Button>}
            title="Share Room Access"
            body={<SharedAccessForm />}
          />
        </Card.Body>
      </Card>
    </div>
  );
}
