import React from 'react';
import PropTypes from 'prop-types';
import { Row } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';
import RegistrationForm from './forms/RegistrationForm';

export default function Registration({ value }) {
  const { t } = useTranslation();

  return (
    <Row className="mb-3">
      <h6> { t('admin.site_settings.registration.role_mapping_by_email') } </h6>
      <p className="text-muted"> { t('admin.site_settings.registration.role_mapping_by_email_description') } </p>
      <RegistrationForm
        mutation={() => useUpdateSiteSetting('RoleMapping')}
        value={value}
      />
    </Row>
  );
}

Registration.defaultProps = {
  value: '',
};

Registration.propTypes = {
  value: PropTypes.string,
};
