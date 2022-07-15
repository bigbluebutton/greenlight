import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, Stack, Table,
} from 'react-bootstrap';
import { useFieldArray, useForm } from 'react-hook-form';
import Form from '../Form';
import { RegistrationFormConfig } from '../../../helpers/forms/RegistrationFormHelpers';
import RegistrationRow from './RegistrationRow';

export default function RegistrationForm({ rolesMap }) {
  const { defaultValues } = RegistrationFormConfig;
  defaultValues.roles_map = rolesMap;

  const methods = useForm(RegistrationFormConfig);
  const errors = methods.formState.errors.roles_map;
  const { fields, append, remove } = useFieldArray({ control: methods.control, name: 'roles_map' });

  return (
    <Form methods={methods} onSubmit={(data) => console.log(data)}>
      <Table hover bordered className="text-secondary mb-0">
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-end-0">Role Name</th>
            <th className="fw-normal border-0">Email Suffix</th>
            <th className="border-start-0" aria-label="options" />
          </tr>
        </thead>
        <tbody className="border-top-0">
          {(
            fields.length && (fields.map((item, index) => (
              <RegistrationRow
                key={item.id}
                index={index}
                errors={errors}
                remove={remove}
              />
            )))
          ) || (
            <tr>
              <td className="text-center" colSpan="3">
                No roles mapping rule, click <strong>Add</strong> to add new one.
              </td>
            </tr>
          )}
        </tbody>
        <tfoot className="text-muted small">
          <tr>
            <td colSpan="3">
              <Stack className="mt-1" direction="horizontal" gap={1}>
                <Button variant="outline-primary" className="" onClick={() => methods.reset(defaultValues)}>
                  Reset
                </Button>
                <Button variant="outline-primary" onClick={() => append({ name: '', suffix: '' })}>
                  Add
                </Button>
                <Button className="ms-auto" variant="primary" type="submit">
                  Update
                </Button>
              </Stack>
            </td>
          </tr>
        </tfoot>
      </Table>
    </Form>
  );
}

RegistrationForm.defaultProps = {
  rolesMap: [],
};

RegistrationForm.propTypes = {
  rolesMap: PropTypes.arrayOf(PropTypes.shape({
    name: PropTypes.string.isRequired,
    suffix: PropTypes.string.isRequired,
  }).isRequired),
};
