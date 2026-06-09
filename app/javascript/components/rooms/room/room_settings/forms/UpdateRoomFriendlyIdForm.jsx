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
import { useNavigate } from 'react-router-dom';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import useRoom from '../../../../../hooks/queries/rooms/useRoom';
import useUpdateRoom from '../../../../../hooks/mutations/rooms/useUpdateRoom';

export default function UpdateRoomFriendlyIdForm({ friendlyId }) {
  const { t } = useTranslation();
  const { register, handleSubmit } = useForm();
  const { data: room } = useRoom(friendlyId);
  const updateRoom = useUpdateRoom({ friendlyId });
  const navigate = useNavigate();

  const submit = (data) => {
    const newFriendlyId = data.room.friendly_id;
    updateRoom.mutate(data, {
      onSuccess: () => navigate(`/rooms/${newFriendlyId}`),
    });
  };

  return (
    <Row className="mt-3">
      <h6 className="text-brand">{ t('room.room_id') }</h6>
      <Form onSubmit={handleSubmit(submit)}>
        <Stack direction="horizontal">
          <Form.Control
            type="text"
            defaultValue={room.friendly_id}
            {...register('room.friendly_id', {
              minLength: 3,
              maxLength: 50,
              pattern: /^[a-z0-9][a-z0-9-]*[a-z0-9]$/,
            })}
          />
          <Button type="submit" variant="brand" className="ms-3">{ t('update') }</Button>
        </Stack>
      </Form>
    </Row>
  );
}

UpdateRoomFriendlyIdForm.propTypes = {
  friendlyId: PropTypes.string.isRequired,
};
