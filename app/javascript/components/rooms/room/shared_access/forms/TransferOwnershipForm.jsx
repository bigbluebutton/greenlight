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

/* eslint-disable react/jsx-props-no-spreading */

import React, { useState } from 'react';
import {
  Alert, Button, Form, Stack, Table,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ExclamationTriangleIcon } from '@heroicons/react/24/outline';
import useTransferOwnership from '../../../../../hooks/mutations/rooms/useTransferOwnership';
import Avatar from '../../../../users/user/Avatar';
import SearchBar from '../../../../shared_components/search/SearchBar';
import useTransferableUsers from '../../../../../hooks/queries/shared_accesses/useTransferableUsers';

export default function TransferOwnershipForm({ handleClose }) {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const transferOwnership = useTransferOwnership({ friendlyId, closeModal: handleClose });
  const [searchInput, setSearchInput] = useState();
  const [selectedUserId, setSelectedUserId] = useState(null);
  const { data: transferableUsers } = useTransferableUsers(friendlyId, searchInput);

  const onSubmit = (event) => {
    event.preventDefault();
    if (!selectedUserId) return;
    transferOwnership.mutate({ new_owner_id: selectedUserId });
  };

  return (
    <div id="transfer-ownership-form">
      <Alert variant="danger" className="d-flex align-items-start gap-2">
        <ExclamationTriangleIcon className="hi-s flex-shrink-0 mt-1" />
        <span>{t('room.shared_access.transfer_ownership_warning')}</span>
      </Alert>
      <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
      <Form onSubmit={onSubmit}>
        <div className="table-scrollbar-wrapper">
          <Table hover responsive className="text-secondary my-3">
            <thead>
              <tr className="text-muted small">
                <th className="fw-normal">{ t('user.name') }</th>
              </tr>
            </thead>
            <tbody className="border-top-0">
              {
                (() => {
                  if (searchInput?.length >= 3 && transferableUsers?.length) {
                    return (
                      transferableUsers.map((user) => (
                        <tr
                          key={user.id}
                          className="align-middle"
                        >
                          <td>
                            <Stack direction="horizontal" className="py-2">
                              <Form.Label className="w-100 mb-0 text-brand">
                                <Form.Check
                                  id={`${user.id}-radio`}
                                  type="radio"
                                  name="transfer-owner"
                                  value={user.id}
                                  className="d-inline-block"
                                  checked={selectedUserId === user.id}
                                  onChange={() => setSelectedUserId(user.id)}
                                />
                                <Avatar avatar={user.avatar} size="small" className="d-inline-block px-3" />
                                {user.name}
                              </Form.Label>
                            </Stack>
                          </td>
                        </tr>
                      )));
                  } if (searchInput?.length >= 3) {
                    return (<tr className="fw-bold"><td>{ t('user.no_user_found') }</td><td /></tr>);
                  }
                  return (<tr className="fw-bold"><td colSpan="2">{ t('user.type_three_characters') }</td></tr>);
                })()
              }
            </tbody>
          </Table>
        </div>
        <Stack id="transfer-ownership-modal-buttons" className="mt-3" direction="horizontal" gap={1}>
          <Button variant="neutral" className="ms-auto" onClick={handleClose}>
            { t('close') }
          </Button>
          <Button variant="danger" type="submit" disabled={!selectedUserId}>
            { t('room.shared_access.transfer_ownership') }
          </Button>
        </Stack>
      </Form>
    </div>
  );
}

TransferOwnershipForm.propTypes = {
  handleClose: PropTypes.func,
};

TransferOwnershipForm.defaultProps = {
  handleClose: () => { },
};
