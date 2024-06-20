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
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import useRoomForm from '../../../../hooks/forms/rooms/useRoomForm';

export default function CreateRoomForm({ mutation: useCreateRoomAPI, userId, handleClose }) {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const createRoomAPI = useCreateRoomAPI({ onSettled: handleClose, user_id: currentUser.id });
  const { methods, fields } = useRoomForm({ defaultValues: { user_id: userId } });

  return (
    <Form methods={methods} onSubmit={createRoomAPI.mutate}>
      <FormControl field={fields.name} type="text" />
      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="neutral" className="ms-auto" onClick={handleClose}>
          { t('close') }
        </Button>
        <Button variant="brand" type="submit" disabled={createRoomAPI.isLoading}>
          {createRoomAPI.isLoading && <Spinner className="me-2" />}
          { t('room.create_room') }
        </Button>
      </Stack>
    </Form>
  );
}

CreateRoomForm.propTypes = {
  handleClose: PropTypes.func,
  mutation: PropTypes.func.isRequired,
  userId: PropTypes.string.isRequired,
};

CreateRoomForm.defaultProps = {
  handleClose: () => { },
};
