import React, { useState } from 'react';
import {
  Button, Card, Stack, Table,
} from 'react-bootstrap';
import { TrashIcon } from '@heroicons/react/24/outline';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Modal from '../../../shared_components/modals/Modal';
import SharedAccessForm from './forms/SharedAccessForm';
import Avatar from '../../../users/user/Avatar';
import SearchBarQuery from '../../../shared_components/search/SearchBarQuery';
import useDeleteSharedAccess from '../../../../hooks/mutations/shared_accesses/useDeleteSharedAccess';
import useSharedUsers from '../../../../hooks/queries/shared_accesses/useSharedUsers';
import SharedAccessEmpty from './SharedAccessEmpty';

export default function SharedAccess() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const [input, setInput] = useState();
  const { data: sharedUsers } = useSharedUsers(friendlyId, input);
  const deleteSharedAccess = useDeleteSharedAccess(friendlyId);

  if (sharedUsers?.length || input) {
    return (
      <div id="shared-access-list">
        <Stack direction="horizontal" className="w-100 mt-3">
          <div>
            <SearchBarQuery setInput={setInput} />
          </div>
          <Modal
            modalButton={<Button variant="brand-outline" className="ms-auto">{ t('room.shared_access.add_share_access')}</Button>}
            title={t('room.shared_access.share_room_access')}
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
                  <th className="fw-normal w-50">{ t('user.name') }</th>
                  <th className="fw-normal w-50">{ t('user.email_address') }</th>
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
                            <h6 className="text-brand mb-0 ps-3"> {user.name} </h6>
                          </Stack>
                        </td>
                        <td>
                          <span className="text-muted"> {user.email} </span>
                          <Button
                            variant="icon"
                            className="float-end pe-2"
                            onClick={() => deleteSharedAccess.mutate({ user_id: user.id })}
                          >
                            <TrashIcon className="hi-s" />
                          </Button>
                        </td>
                      </tr>
                    ))
                  )
                  : (
                    <tr className="fw-bold"><td>{ t('user.no_user_found') }</td></tr>
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
