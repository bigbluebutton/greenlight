import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, InputGroup,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import Form from '../Form';
import { RegistrationFormFields, RegistrationFormConfig } from '../../../helpers/forms/RegistrationFormHelpers';
import Spinner from '../../shared/stylings/Spinner';
import FormControlGeneric from '../FormControlGeneric';

export default function RegistrationForm({ value, mutation: useUpdateSiteSettingsAPI }) {
  const updateSiteSettingsAPI = useUpdateSiteSettingsAPI();

  const { defaultValues } = RegistrationFormConfig;
  defaultValues.value = value;
  const fields = RegistrationFormFields;
  const methods = useForm(RegistrationFormConfig);

  return (
    <Form methods={methods} onSubmit={updateSiteSettingsAPI.mutate}>
      <InputGroup>
        <FormControlGeneric
          field={fields.value}
          aria-describedby="RegistrationForm-submit-btn"
          type="text"
        />
        <Button id="RegistrationForm-submit-btn" variant="primary" type="submit" disabled={updateSiteSettingsAPI.isLoading}>
          Update
          {updateSiteSettingsAPI.isLoading && <Spinner />}
        </Button>
      </InputGroup>
    </Form>
  );
}

RegistrationForm.defaultProps = {
  value: '',
};

RegistrationForm.propTypes = {
  value: PropTypes.string,
  mutation: PropTypes.func.isRequired,
};
