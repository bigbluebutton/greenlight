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

import React from 'react';
import { Button, Stack } from 'react-bootstrap';
import { ExclamationTriangleIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import useUnshareRoom from '../../../../hooks/mutations/shared_accesses/useUnshareRoom';
import Spinner from '../../../shared_components/utilities/Spinner';

export default function UnshareRoom({ userId, roomFriendlyId, handleClose }) {
  const { t } = useTranslation();

  const deleteSharedAccess = useUnshareRoom(roomFriendlyId);

  const handleDelete = () => {
    deleteSharedAccess.mutate({ user_id: userId });
    handleClose();
  };

  return (
    <>
      <Stack direction="horizontal" className="mb-3">
        <ExclamationTriangleIcon className="text-danger hi-xl" />
        <Stack direction="vertical" className="ps-3">
          <h3> { t('room.shared_access.delete_shared_access') } </h3>
          <p className="mb-0"> { t('room.shared_access.are_you_sure_delete_shared_access') } </p>
          <p className="mt-0"><strong> { t('action_permanent') } </strong></p>
        </Stack>
      </Stack>
      <Stack direction="horizontal" gap={1} className="float-end">
        <Button variant="neutral" onClick={handleClose}>
          { t('close') }
        </Button>
        <Button variant="danger" type="submit" disabled={deleteSharedAccess.isLoading} onClick={() => handleDelete()}>
          { deleteSharedAccess.isLoading && <Spinner className="me-2" /> }
          { t('delete') }
        </Button>
      </Stack>
    </>
  );
}

UnshareRoom.defaultProps = {
  handleClose: () => {},
};

UnshareRoom.propTypes = {
  userId: PropTypes.string.isRequired,
  roomFriendlyId: PropTypes.string.isRequired,
  handleClose: PropTypes.func,
};
