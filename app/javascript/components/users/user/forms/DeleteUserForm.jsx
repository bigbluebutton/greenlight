import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from '../../../forms/Form';
import useDeleteUser from '../../../../hooks/mutations/users/useDeleteUser';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import Spinner from '../../../shared_components/stylings/Spinner';

export default function DeleteUserForm({ handleClose }) {
  const currentUser = useAuth();
  const methods = useForm();
  const deleteUserAPI = useDeleteUser(currentUser?.id);

  return (
    <>
      <p className="text-center"> Are you sure you want to delete your account?</p>
      <Form methods={methods} onSubmit={deleteUserAPI.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="primary-reverse" onClick={handleClose}>
            Close
          </Button>
          <Button variant="danger" type="submit" disabled={deleteUserAPI.isLoading}>
            Delete
            { deleteUserAPI.isLoading && <Spinner /> }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteUserForm.propTypes = {
  handleClose: PropTypes.func,
};

DeleteUserForm.defaultProps = {
  handleClose: () => {},
};
