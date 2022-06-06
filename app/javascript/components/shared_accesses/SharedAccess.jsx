import React, { useState } from 'react';
import {
  Button, Card, Stack, Table,
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
        <Stack direction="horizontal" className="w-100 mt-3">
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
        <Card className="border-0 shadow-sm mt-3">
          <Card.Body className="p-0">
            <Table hover className="text-secondary mb-0">
              <thead>
                <tr className="text-muted small">
                  <th className="fw-normal w-50">Name</th>
                  <th className="fw-normal w-50">Email address</th>
                </tr>
              </thead>
              <tbody className="border-top-0">
                {sharedUsers?.length
                  ? (
                    sharedUsers?.map((user) => (
                      <tr key={user.id} className="align-middle">
                        <td>
                          <Stack direction="horizontal" className="py-2">
                            <Avatar avatar={user.avatar} radius={40} />
                            <h6 className="text-primary mb-0 ps-3"> {user.name} </h6>
                          </Stack>
                        </td>
                        <td>
                          <span className="text-muted"> {user.email} </span>
                          <Button
                            variant="font-awesome"
                            className="float-end pe-2"
                            onClick={() => handleDeleteSharedAccess({ user_id: user.id })}
                          >
                            <FontAwesomeIcon icon={faTrashAlt} />
                          </Button>
                        </td>
                      </tr>
                    ))
                  )
                  : (
                    <tr className="fw-bold"><td>No user found! </td></tr>
                  )}
              </tbody>
            </Table>
          </Card.Body>
        </Card>
      </div>
    );
  }
  return <SharedAccessEmpty />;
}
