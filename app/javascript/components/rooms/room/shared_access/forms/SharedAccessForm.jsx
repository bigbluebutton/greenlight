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
  Button, Form, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import useShareAccess from '../../../../../hooks/mutations/shared_accesses/useShareAccess';
import SearchBar from '../../../../shared_components/search/SearchBar';
import useShareableUsers from '../../../../../hooks/queries/shared_accesses/useShareableUsers';
import UserSearchTable from './UserSearchTable';

export default function SharedAccessForm({ handleClose }) {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const createSharedUser = useShareAccess({ friendlyId, closeModal: handleClose });
  const [searchInput, setSearchInput] = useState();
  const [selectedUsers, setSelectedUsers] = useState([]);
  const { data: shareableUsers } = useShareableUsers(friendlyId, searchInput);

  const toggleUserSelection = (userId) => {
    setSelectedUsers((prev) => {
      if (prev.includes(userId)) {
        return prev.filter((id) => id !== userId);
      }
      return [...prev, userId];
    });
  };

  const onSubmit = (event) => {
    event.preventDefault();
    if (!selectedUsers.length) return;
    createSharedUser.mutate({ shared_users: selectedUsers });
  };

  return (
    <div id="shared-access-form">
      <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
      <Form onSubmit={onSubmit}>
        <UserSearchTable
          users={shareableUsers}
          searchInput={searchInput}
          inputType="checkbox"
          isChecked={(userId) => selectedUsers.includes(userId)}
          onChange={toggleUserSelection}
        />
        <Stack id="shared-access-modal-buttons" className="mt-3" direction="horizontal" gap={1}>
          <Button variant="neutral" className="ms-auto" onClick={handleClose}>
            { t('close') }
          </Button>
          <Button variant="brand" type="submit" disabled={!selectedUsers.length}>
            { t('share') }
          </Button>
        </Stack>
      </Form>
    </div>
  );
}

SharedAccessForm.propTypes = {
  handleClose: PropTypes.func,
};

SharedAccessForm.defaultProps = {
  handleClose: () => { },
};
