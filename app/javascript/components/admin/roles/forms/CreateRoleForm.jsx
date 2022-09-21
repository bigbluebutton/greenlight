import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import { createRoleFormConfig, createRoleFormFields } from '../../../../helpers/forms/CreateRoleFormHelpers';
import useCreateRole from '../../../../hooks/mutations/admin/roles/useCreateRole';

export default function CreateRoleForm({ handleClose }) {
  const createRole = useCreateRole({ onSettled: handleClose });
  const methods = useForm(createRoleFormConfig);
  const fields = createRoleFormFields;

  return (
    <Form methods={methods} onSubmit={createRole.mutate}>
      <FormControl field={fields.name} type="text" />
      <Stack className="mt-1" direction="horizontal" gap={1}>
        <Button variant="brand-backward" className="ms-auto" onClick={handleClose}>
          Close
        </Button>
        <Button variant="brand" type="submit" disabled={createRole.isLoading}>
          Create Role
          {createRole.isLoading && <Spinner />}
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
