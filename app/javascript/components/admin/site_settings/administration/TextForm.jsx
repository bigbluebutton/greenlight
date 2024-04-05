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

import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import useTextForm from '../../../../hooks/forms/admin/site_settings/useTextForm';

export default function TextForm({ id, value, mutation: useUpdateSiteSettingsAPI }) {
  const updateSiteSettingsAPI = useUpdateSiteSettingsAPI();
  const { t } = useTranslation();
  const maintenanceBannerId = localStorage.getItem('maintenanceBannerId');

  const { methods, fields } = useTextForm({ defaultValues: { value } });

  // Function to clear the form
  const clearForm = () => {
    methods.reset({ value: '' });
    toast.dismiss(maintenanceBannerId);
    updateSiteSettingsAPI.mutate('');
  };

  return (
    <Form id={id} methods={methods} onSubmit={updateSiteSettingsAPI.mutate}>
      <FormControl
        field={fields.value}
        aria-describedby={`${id}-submit-btn`}
        type="text"
        noLabel
      />
      <Button id={`${id}-clear-btn`} className="mb-2 float-end" variant="brand" onClick={clearForm} disabled={updateSiteSettingsAPI.isLoading}>
        {updateSiteSettingsAPI.isLoading && <Spinner className="me-2" />}
        { t('admin.site_settings.administration.clear_banner') }
      </Button>
      <Button id={`${id}-submit-btn`} className="mb-2 float-end me-2" variant="brand" type="submit" disabled={updateSiteSettingsAPI.isLoading}>
        {updateSiteSettingsAPI.isLoading && <Spinner className="me-2" />}
        { t('admin.site_settings.administration.set_text') }
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
