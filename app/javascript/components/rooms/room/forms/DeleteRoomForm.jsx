import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from '../../../forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';

export default function DeleteRoomForm({ mutation: useDeleteRoomAPI, handleClose }) {
  const deleteRoomAPI = useDeleteRoomAPI({ onSettled: handleClose });
  const methods = useForm();

  return (
    <>
      <p className="text-center"> Are you sure you want to delete this room?</p>
      <Form methods={methods} onSubmit={deleteRoomAPI.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="primary-reverse" onClick={handleClose}>
            Close
          </Button>
          <Button variant="danger" type="submit" disabled={deleteRoomAPI.isLoading}>
            Delete
            { deleteRoomAPI.isLoading && <Spinner /> }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteRoomForm.propTypes = {
  handleClose: PropTypes.func,
  mutation: PropTypes.func.isRequired,
};

DeleteRoomForm.defaultProps = {
  handleClose: () => {},
};
