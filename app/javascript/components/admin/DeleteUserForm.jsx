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

export default function DeleteUserForm({ user, handleClose }) {
  const methods = useForm();
  const { isSubmitting } = methods.formState;
  const { onSubmit } = useDeleteUser(user?.id);

  return (
    <>
      <p className="text-center"> Are you sure you want to delete {user.name}&rsquo;s account?
        <br />
        If you choose to delete this account, it will NOT be recoverable.
      </p>
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
  user: PropTypes.shape({
    id: PropTypes.number.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
  handleClose: PropTypes.func,
};

DeleteUserForm.defaultProps = {
  handleClose: () => {},
};
