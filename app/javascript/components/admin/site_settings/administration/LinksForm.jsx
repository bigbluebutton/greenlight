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
import Form from '../../../shared_components/forms/Form';
import Spinner from '../../../shared_components/utilities/Spinner';
import FormControl from '../../../shared_components/forms/FormControl';
import useLinksForm from '../../../../hooks/forms/admin/site_settings/useLinksForm';

export default function LinksForm({ id, value, mutation: useUpdateSiteSettingsAPI }) {
  const updateSiteSettingsAPI = useUpdateSiteSettingsAPI();
  const { t } = useTranslation();

  const { methods, fields } = useLinksForm({ defaultValues: { value } });

  return (
    <Form id={id} methods={methods} onSubmit={updateSiteSettingsAPI.mutate}>
      <FormControl
        field={fields.value}
        aria-describedby={`${id}-submit-btn`}
        type="text"
        noLabel
      />
      <Button id={`${id}-submit-btn`} className="mb-2 float-end" variant="brand" type="submit" disabled={updateSiteSettingsAPI.isLoading}>
        {updateSiteSettingsAPI.isLoading && <Spinner className="me-2" />}
        { t('admin.site_settings.administration.change_url') }
      </Button>
    </Form>
  );
}

LinksForm.propTypes = {
  id: PropTypes.string.isRequired,
  mutation: PropTypes.func.isRequired,
  value: PropTypes.string,
};

LinksForm.defaultProps = {
  value: '',
};
