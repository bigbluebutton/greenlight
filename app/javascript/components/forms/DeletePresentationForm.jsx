import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import PropTypes from 'prop-types';
import Form from './Form';
import Spinner from '../shared/stylings/Spinner';
import useDeletePresentation from '../../hooks/mutations/rooms/useDeletePresentation';

export default function DeletePresentationForm({ handleClose }) {
  const methods = useForm();
  const { friendlyId } = useParams();
  const deletePresentation = useDeletePresentation(friendlyId);
  return (
    <>
      <p className="text-center"> Are you sure you want to delete this presentation?</p>
      <Form methods={methods} onSubmit={deletePresentation.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="primary-reverse" onClick={handleClose}>
            Close
          </Button>
          <Button variant="danger" type="submit" disabled={deletePresentation.isLoading}>
            Delete
            { deletePresentation.isLoading && <Spinner /> }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeletePresentationForm.propTypes = {
  handleClose: PropTypes.func,
};

DeletePresentationForm.defaultProps = {
  handleClose: () => {},
};
