import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from '../../forms/Form';
import Spinner from '../../shared_components/utilities/Spinner';

export default function DeleteRecordingForm({ mutation: useDeleteAPI, recordId, handleClose }) {
  const methods = useForm();
  const deleteAPI = useDeleteAPI({ recordId, onSettled: handleClose });

  return (
    <>
      <p className="text-center"> Are you sure you want to delete this recording?</p>
      <Form methods={methods} onSubmit={deleteAPI.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="primary-reverse" onClick={handleClose}>
            Close
          </Button>
          <Button variant="danger" type="submit" disabled={deleteAPI.isLoading}>
            Delete
            {deleteAPI.isLoading && <Spinner />}
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteRecordingForm.propTypes = {
  handleClose: PropTypes.func,
  recordId: PropTypes.string,
  mutation: PropTypes.func.isRequired,
};

DeleteRecordingForm.defaultProps = {
  handleClose: () => { },
  recordId: -1,
};
