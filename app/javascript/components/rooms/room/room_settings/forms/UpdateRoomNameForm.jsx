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

import React from 'react';
import {
  Button, Row, Stack, Form,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import useRoom from '../../../../../hooks/queries/rooms/useRoom';
import useUpdateRoom from '../../../../../hooks/mutations/rooms/useUpdateRoom';

export default function UpdateRoomNameForm({ friendlyId }) {
  const { t } = useTranslation();
  const {
    register,
    handleSubmit,
  } = useForm();
  const { data: room } = useRoom(friendlyId);
  const updateRoom = useUpdateRoom({ friendlyId });

  return (
    <Row>
      <h6 className="text-brand">{ t('room.room_name') }</h6>
      <Form onSubmit={handleSubmit(updateRoom.mutate)}>
        <Stack direction="horizontal">
          <Form.Control type="text" defaultValue={room.name} {...register('room.name', { minLength: 2, maxLength: 255 })} />
          <Button type="submit" variant="brand" className="ms-3"> { t('update') } </Button>
        </Stack>
      </Form>

    </Row>
  );
}

UpdateRoomNameForm.propTypes = {
  friendlyId: PropTypes.string.isRequired,
};
