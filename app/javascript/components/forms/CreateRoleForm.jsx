import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from './Form';
import Spinner from '../shared/stylings/Spinner';
import FormControl from './FormControl';
import { createRoleFormConfig, createRoleFormFields } from '../../helpers/forms/CreateRoleFormHelpers';

export default function CreateRoleForm({ handleClose }) {
  const methods = useForm(createRoleFormConfig);
  const { isSubmitting } = methods.formState;
  const fields = createRoleFormFields;

  return (
    <Form methods={methods} onSubmit={() => console.log('Submitted.')}>
      <FormControl field={fields.name} type="text" />
      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="primary-light" className="ms-auto" onClick={handleClose}>
          Close
        </Button>
        <Button variant="primary" type="submit" disabled={isSubmitting}>
          Create Role
          {isSubmitting && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}

CreateRoleForm.propTypes = {
  handleClose: PropTypes.func,
};

CreateRoleForm.defaultProps = {
  handleClose: () => { },
};
