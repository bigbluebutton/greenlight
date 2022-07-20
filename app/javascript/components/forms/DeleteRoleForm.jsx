import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from './Form';
import Spinner from '../shared/stylings/Spinner';

export default function DeleteRoleForm({ handleClose }) {
  const methods = useForm();
  const { isSubmitting } = methods.formState;

  return (
    <>
      <p className="text-center"> Are you sure you want to delete this role?</p>
      <Form methods={methods} onSubmit={() => { console.log('Deleted Role.'); }}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="primary-reverse" onClick={handleClose}>
            Close
          </Button>
          <Button variant="danger" type="submit" disabled={isSubmitting}>
            Delete
            {isSubmitting && <Spinner />}
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeleteRoleForm.propTypes = {
  handleClose: PropTypes.func,
};

DeleteRoleForm.defaultProps = {
  handleClose: () => { },
};
