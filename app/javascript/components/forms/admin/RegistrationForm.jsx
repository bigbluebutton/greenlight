import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, Stack, Table,
} from 'react-bootstrap';
import { useFieldArray, useForm } from 'react-hook-form';
import Form from '../Form';
import { RegistrationFormConfig } from '../../../helpers/forms/RegistrationFormHelpers';
import RegistrationRow from './RegistrationRow';
import useUpdateSiteSetting from '../../../hooks/mutations/admins/site-settings/useUpdateSiteSetting';
import Spinner from '../../shared/stylings/Spinner';

export default function RegistrationForm({ value }) {
  const updateSiteSettingsAPI = useUpdateSiteSetting('RoleMapping');

  const { defaultValues } = RegistrationFormConfig;
  defaultValues.value = value;
  const methods = useForm(RegistrationFormConfig);
  const errors = methods.formState.errors.value;
  const { fields, append, remove } = useFieldArray({ control: methods.control, name: 'value' });

  return (
    <Form methods={methods} onSubmit={updateSiteSettingsAPI.mutate}>
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
                <Button className="ms-auto" variant="primary" type="submit" disabled={updateSiteSettingsAPI.isLoading}>
                  Update
                  {updateSiteSettingsAPI.isLoading && <Spinner />}
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
  value: [],
};

RegistrationForm.propTypes = {
  value: PropTypes.arrayOf(PropTypes.shape({
    name: PropTypes.string.isRequired,
    suffix: PropTypes.string.isRequired,
  }).isRequired),
};
