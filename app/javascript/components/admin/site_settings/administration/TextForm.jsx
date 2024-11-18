// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React, { useCallback, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import useTextForm from '../../../../hooks/forms/admin/site_settings/useTextForm';

export default function TextForm({ id, value, mutation: useUpdateSiteSettingsAPI }) {
  const updateSiteSettingsAPISetText = useUpdateSiteSettingsAPI();
  const updateSiteSettingsAPIClearText = useUpdateSiteSettingsAPI();

  const { t } = useTranslation();

  const { methods, fields } = useTextForm({ defaultValues: { value } });

  const formText = useRef('');

  useEffect(() => {
    if (methods) {
      methods.reset({ value });
      formText.current = value;
    }
  }, [methods, value]);

  const dismissMaintenanceBannerToast = () => {
    const maintenanceBannerId = localStorage.getItem('maintenanceBannerId');
    if (maintenanceBannerId) {
      toast.dismiss(maintenanceBannerId);
      localStorage.removeItem('maintenanceBannerId');
    }
  };

  // Function to clear the form
  const clearForm = () => {
    methods.reset({ value: '' });
    dismissMaintenanceBannerToast();
    if (formText.current) {
      formText.current = '';
      updateSiteSettingsAPIClearText.mutate('');
    }
  };

  const handleSubmit = useCallback((formData) => {
    if (formText.current !== formData[`${fields.value.hookForm.id}`]) {
      dismissMaintenanceBannerToast();
      formText.current = formData[`${fields.value.hookForm.id}`];
      return updateSiteSettingsAPISetText.mutate(formData);
    }
    return null;
  }, [updateSiteSettingsAPISetText.mutate]);

  return (
    <Form id={id} methods={methods} onSubmit={handleSubmit}>
      <FormControl
        field={fields.value}
        aria-describedby={`${id}-submit-btn`}
        type="text"
        as="textarea"
        rows={3}
        noLabel
      />
      <Button
        id={`${id}-clear-btn`}
        className="mb-2 float-end"
        variant="danger"
        onClick={clearForm}
        disabled={updateSiteSettingsAPIClearText.isLoading}
      >
        {updateSiteSettingsAPIClearText.isLoading && (
          <Spinner className="me-2" />
        )}
        {t('admin.site_settings.administration.clear_banner')}
      </Button>
      <Button
        id={`${id}-submit-btn`}
        className="mb-2 float-end me-2"
        variant="brand"
        type="submit"
        disabled={updateSiteSettingsAPISetText.isLoading}
      >
        {updateSiteSettingsAPISetText.isLoading && <Spinner className="me-2" />}
        {t('admin.site_settings.administration.set_text')}
      </Button>
    </Form>
  );
}

TextForm.propTypes = {
  id: PropTypes.string.isRequired,
  mutation: PropTypes.func.isRequired,
  value: PropTypes.string,
};

TextForm.defaultProps = {
  value: '',
};
