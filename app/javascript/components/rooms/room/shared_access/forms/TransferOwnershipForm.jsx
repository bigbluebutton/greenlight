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
  Alert, Button, Form, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ExclamationTriangleIcon } from '@heroicons/react/24/outline';
import useTransferOwnership from '../../../../../hooks/mutations/rooms/useTransferOwnership';
import SearchBar from '../../../../shared_components/search/SearchBar';
import useTransferableUsers from '../../../../../hooks/queries/shared_accesses/useTransferableUsers';
import UserSearchTable from './UserSearchTable';

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
        <UserSearchTable
          users={transferableUsers}
          searchInput={searchInput}
          inputType="radio"
          inputName="transfer-owner"
          isChecked={(userId) => selectedUserId === userId}
          onChange={setSelectedUserId}
        />
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
