import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from './Form';
import Spinner from '../shared/stylings/Spinner';
import useDeleteRoom from '../../hooks/mutations/rooms/useDeleteRoom';

export default function DeleteRoomForm({ friendlyId, handleClose }) {
  const methods = useForm();
  const { isSubmitting } = methods.formState;
  const deleteRoom = useDeleteRoom(friendlyId);

  return (
    <>
      <p className="text-center"> Are you sure you want to delete this room?</p>
      <Form methods={methods} onSubmit={deleteRoom.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="primary-reverse" onClick={handleClose}>
            Close
          </Button>
          <Button variant="danger" type="submit" disabled={isSubmitting}>
            Delete
            { isSubmitting && <Spinner /> }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteRoomForm.propTypes = {
  friendlyId: PropTypes.string,
  handleClose: PropTypes.func,
};

DeleteRoomForm.defaultProps = {
  friendlyId: '',
  handleClose: () => {},
};
