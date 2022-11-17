import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, InputGroup,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import Form from '../../../../shared_components/forms/Form';
import { RegistrationFormFields, RegistrationFormConfig } from '../../../../../helpers/forms/RegistrationFormHelpers';
import Spinner from '../../../../shared_components/utilities/Spinner';
import FormControlGeneric from '../../../../shared_components/forms/FormControlGeneric';

export default function RegistrationForm({ value, mutation: useUpdateSiteSettingsAPI }) {
  const { t } = useTranslation();
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
        <Button id="RegistrationForm-submit-btn" variant="brand" type="submit" disabled={updateSiteSettingsAPI.isLoading}>
          {updateSiteSettingsAPI.isLoading && <Spinner className="me-2" />}
          { t('update') }
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
