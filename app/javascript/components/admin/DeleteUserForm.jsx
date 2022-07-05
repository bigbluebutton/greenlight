import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form
  from '../forms/Form';
import useDeleteUser from '../../hooks/mutations/admins/useDeleteUser';
import Spinner from '../shared/stylings/Spinner';

export default function DeleteUserForm({ userId, handleClose }) {
  const methods = useForm();
  const { isSubmitting } = methods.formState;
  const { onSubmit } = useDeleteUser(userId);

  return (
    <>
      <p className="text-center"> Are you sure you want to delete your account?</p>
      <Form methods={methods} onSubmit={onSubmit}>
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

DeleteUserForm.propTypes = {
  handleClose: PropTypes.func,
  userId: PropTypes.string.isRequired,
};

DeleteUserForm.defaultProps = {
  handleClose: () => {},
};
