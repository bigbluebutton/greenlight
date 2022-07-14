import React from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { editRoleFormConfig, editRoleFormFields } from '../../../helpers/forms/EditRoleFormHelpers';
import Form from '../Form';
import FormControl from '../FormControl';
import Spinner from '../../shared/stylings/Spinner';

export default function EditRoleForm({ role }) {
  const { defaultValues } = editRoleFormConfig;
  defaultValues.name = role.name;

  const methods = useForm(editRoleFormConfig);
  const { isSubmitting } = methods.formState;
  const fields = editRoleFormFields;
  fields.name.placeHolder = defaultValues.name;

  return (
    <Form methods={methods} onSubmit={(data) => { console.log(data); }}>
      <FormControl field={fields.name} type="text" />
      <Stack className="mt-1 float-end" gap={2} direction="horizontal">
        <Button className="danger-light-button">
          Delete Role
        </Button>
        <Button
          variant="outline-primary"
          onClick={() => methods.reset(defaultValues)}
        >
          Cancel
        </Button>
        <Button variant="primary" type="submit" disabled={isSubmitting}>
          Update
          {isSubmitting && <Spinner />}
        </Button>
      </Stack>
    </Form>
  );
}

EditRoleForm.propTypes = {
  role: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  }).isRequired,
};
