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
          <Button type="submit" variant="brand" className="ms-3"> Update </Button>
        </Stack>
      </Form>

    </Row>
  );
}

UpdateRoomNameForm.propTypes = {
  friendlyId: PropTypes.string.isRequired,
};
