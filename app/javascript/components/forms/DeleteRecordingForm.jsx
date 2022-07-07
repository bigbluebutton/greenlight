import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from './Form';
import Spinner from '../shared/stylings/Spinner';
import useDeleteRecording from '../../hooks/mutations/recordings/useDeleteRecording';

export default function DeleteRecordingForm({ recordId, handleClose }) {
  const methods = useForm();
  const deleteRecording = useDeleteRecording(recordId);
  return (
    <>
      <p className="text-center"> Are you sure you want to delete this recording?</p>
      <Form methods={methods} onSubmit={deleteRecording.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="primary-reverse" onClick={handleClose}>
            Close
          </Button>
          <Button variant="danger" type="submit" disabled={deleteRecording.isLoading}>
            Delete
            { deleteRecording.isLoading && <Spinner /> }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteRecordingForm.propTypes = {
  handleClose: PropTypes.func,
  recordId: PropTypes.string,
};

DeleteRecordingForm.defaultProps = {
  handleClose: () => {},
  recordId: -1,
};
