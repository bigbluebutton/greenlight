import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, InputGroup,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControlGeneric from '../../../shared_components/forms/FormControlGeneric';
import useLinksForm from '../../../../hooks/forms/admin/site_settings/useLinksForm';

export default function LinksForm({ id, value, mutation: useUpdateSiteSettingsAPI }) {
  const updateSiteSettingsAPI = useUpdateSiteSettingsAPI();
  const { t } = useTranslation();

  const { methods, fields } = useLinksForm({ defaultValues: { value } });

  return (
    <Form id={id} methods={methods} onSubmit={updateSiteSettingsAPI.mutate}>
      <InputGroup>
        <FormControlGeneric
          field={fields.value}
          aria-describedby={`${id}-submit-btn`}
          type="text"
        />
        <Button id={`${id}-submit-btn`} variant="brand" type="submit" disabled={updateSiteSettingsAPI.isLoading}>
          {updateSiteSettingsAPI.isLoading && <Spinner className="me-2" />}
          { t('admin.site_settings.administration.change_url') }
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
