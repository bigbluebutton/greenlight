import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, Stack
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import useLinksForm from '../../../../hooks/forms/admin/site_settings/useLinksForm';

export default function LinksForm({ id, value, mutation: useUpdateSiteSettingsAPI }) {
  const updateSiteSettingsAPI = useUpdateSiteSettingsAPI();
  const { t } = useTranslation();

  const { methods, fields } = useLinksForm({ defaultValues: { value } });

  return (
    <Form id={id} methods={methods} onSubmit={updateSiteSettingsAPI.mutate} >
      <Stack direction="horizontal" gap={2}>
        <FormControl
          field={fields.value}
          aria-describedby={`${id}-submit-btn`}
          type="text"
          noLabel
        />
        <Button id={`${id}-submit-btn`} variant="brand" type="submit" disabled={updateSiteSettingsAPI.isLoading} className="mb-2">
          {updateSiteSettingsAPI.isLoading && <Spinner className="me-2" />}
          { t('admin.site_settings.administration.change_url') }
        </Button>
      </Stack>
    </Form>
  );
}

LinksForm.propTypes = {
  id: PropTypes.string.isRequired,
  mutation: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
};
