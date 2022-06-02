import React, { useState } from 'react';
import {
  Button, Card, Col, Row, Stack,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrashAlt } from '@fortawesome/free-regular-svg-icons';
import { useParams } from 'react-router-dom';
import Modal from '../shared/Modal';
import SharedAccessForm from '../forms/SharedAccessForm';
import Avatar from '../users/Avatar';
import SearchBarQuery from '../shared/SearchBarQuery';
import useDeleteSharedAccess from '../../hooks/mutations/shared_accesses/useDeleteSharedAccess';
import useSharedUsers from '../../hooks/queries/shared_accesses/useSharedUsers';
import SharedAccessEmpty from './SharedAccessEmpty';

export default function SharedAccess() {
  const { friendlyId } = useParams();
  const [input, setInput] = useState();
  const [sharedUsers, setSharedUsers] = useState();
  useSharedUsers(friendlyId, input, setSharedUsers);
  const { handleDeleteSharedAccess } = useDeleteSharedAccess(friendlyId);

  if (sharedUsers?.length || input) {
    return (
      <div id="shared-access-list" className="wide-background full-height-room">
        <Stack direction="horizontal" className="w-100 mt-5">
          <div>
            <SearchBarQuery setInput={setInput} />
          </div>
          <Modal
            modalButton={<Button variant="primary-light" className="ms-auto">+ Share Access</Button>}
            title="Share Room Access"
            body={<SharedAccessForm />}
            size="lg"
            id="shared-access-modal"
          />
        </Stack>
        <Card className="border-0 shadow-sm mt-4">
          <Card.Body>
            <Row className="border-bottom pb-2">
              <Col>
                <span className="text-muted small"> Name </span>
              </Col>
              <Col>
                <span className="text-muted small"> Email address </span>
              </Col>
            </Row>
            {sharedUsers?.length
              ? (
                sharedUsers?.map((user) => (
                  <Row className="border-bottom py-3" key={user.id}>
                    <Col>
                      <Stack direction="horizontal">
                        <Avatar avatar={user.avatar} radius={40} />
                        <h6 className="text-primary mb-0 ps-3"> {user.name} </h6>
                      </Stack>
                    </Col>
                    <Col className="my-auto">
                      <span className="text-muted"> {user.email} </span>
                      <Button
                        variant="font-awesome"
                        className="float-end pe-2"
                        onClick={() => handleDeleteSharedAccess({ user_id: user.id })}
                      >
                        <FontAwesomeIcon icon={faTrashAlt} />
                      </Button>
                    </Col>
                  </Row>
                ))
              )
              : (
                <p className="fw-bold"> No user found! </p>
              )}
          </Card.Body>
        </Card>
      </div>
    );
  }
  return <SharedAccessEmpty />;
}
