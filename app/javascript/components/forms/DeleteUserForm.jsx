import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from './Form';
import useDeleteUser from '../../hooks/mutations/users/useDeleteUser';
import { useAuth } from '../../contexts/auth/AuthProvider';
import Spinner from '../shared/stylings/Spinner';

export default function DeleteUserForm({ handleClose }) {
  const currentUser = useAuth();
  const methods = useForm();
  const { isSubmitting } = methods.formState;
  const { onSubmit } = useDeleteUser(currentUser?.id);

  return (
    <Form methods={methods} onSubmit={onSubmit}>
      <Stack direction="horizontal" gap={1}>
        <Button variant="secondary" onClick={handleClose}>
          Close
        </Button>
        <Button variant="danger" type="submit" disabled={isSubmitting}>
          Delete
          { isSubmitting && <Spinner /> }
        </Button>
      </Stack>
    </Form>
  );
}

DeleteUserForm.propTypes = {
  handleClose: PropTypes.func,
};

DeleteUserForm.defaultProps = {
  handleClose: () => {},
};
