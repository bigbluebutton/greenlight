import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, InputGroup,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import Form from '../../../shared_components/forms/Form';
import { linksFormConfig, linksFormFields } from '../../../../helpers/forms/LinksFormHelpers';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControlGeneric from '../../../shared_components/forms/FormControlGeneric';

export default function LinksForm({ id, value, mutation: useUpdateSiteSettingsAPI }) {
  const updateSiteSettingsAPI = useUpdateSiteSettingsAPI();

  const { defaultValues } = linksFormConfig;
  defaultValues.value = value;
  const fields = linksFormFields;
  const methods = useForm(linksFormConfig);

  return (
    <Form id={id} methods={methods} onSubmit={updateSiteSettingsAPI.mutate}>
      <InputGroup>
        <FormControlGeneric
          field={fields.value}
          aria-describedby={`${id}-submit-btn`}
          type="text"
        />
        <Button id={`${id}-submit-btn`} variant="brand" type="submit" disabled={updateSiteSettingsAPI.isLoading}>
          Change URL
          {updateSiteSettingsAPI.isLoading && <Spinner />}
        </Button>
      </InputGroup>
    </Form>
  );
}

LinksForm.propTypes = {
  id: PropTypes.string.isRequired,
  mutation: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
};
