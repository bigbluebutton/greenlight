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
import SearchBar from '../../../shared_components/search/SearchBar';
import useDeleteSharedAccess from '../../../../hooks/mutations/shared_accesses/useDeleteSharedAccess';
import useSharedUsers from '../../../../hooks/queries/shared_accesses/useSharedUsers';
import SharedAccessEmpty from './SharedAccessEmpty';
import useRoom from '../../../../hooks/queries/rooms/useRoom';
import { useAuth } from '../../../../contexts/auth/AuthProvider';

export default function SharedAccess() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const [searchInput, setSearchInput] = useState();
  const { data: sharedUsers } = useSharedUsers(friendlyId, searchInput);
  const deleteSharedAccess = useDeleteSharedAccess(friendlyId);
  const { data: room } = useRoom(friendlyId);
  const currentUser = useAuth();
  const isAdmin = currentUser?.role.name === 'Administrator';

  if (sharedUsers?.length || searchInput) {
    return (
      <div id="shared-access-list" className="pt-3">
        <Stack direction="horizontal" className="w-100">
          <div>
            <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
          </div>
          { (!room.shared || isAdmin) && (
            <Modal
              modalButton={(
                <Button
                  variant="brand-outline"
                  className="ms-auto"
                >{t('room.shared_access.add_share_access')}
                </Button>
)}
              title={t('room.shared_access.share_room_access')}
              body={<SharedAccessForm />}
              size="lg"
              id="shared-access-modal"
            />
          )}
        </Stack>
        <Card className="border-0 card-shadow mt-3">
          <Card.Body className="p-0">
            <Table hover responsive className="text-secondary mb-0">
              <thead>
                <tr className="text-muted small">
                  <th className="fw-normal w-75">{ t('user.name') }</th>
                  <th className="fw-normal w-25" aria-label="delete" />
                </tr>
              </thead>
              <tbody className="border-top-0">
                {sharedUsers?.length
                  ? (
                    sharedUsers?.map((user) => (
                      <tr key={user.id} className="align-middle">
                        <td>
                          <Stack direction="horizontal" className="py-2">
                            <Avatar avatar={user.avatar} size="small" />
                            <h6 className="text-brand mb-0 ps-3"> {user.name} </h6>
                          </Stack>
                        </td>
                        <td>
                          { (!room.shared || isAdmin) && (
                          <Button
                            variant="icon"
                            className="float-end pe-2"
                            onClick={() => deleteSharedAccess.mutate({ user_id: user.id })}
                          >
                            <TrashIcon className="hi-s" />
                          </Button>
                          )}
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
