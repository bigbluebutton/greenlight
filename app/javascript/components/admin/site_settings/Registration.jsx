import React from 'react';
import PropTypes from 'prop-types';
import { Container, Row } from 'react-bootstrap';
import useUpdateSiteSetting from '../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';
import RegistrationForm from '../../forms/admin/RegistrationForm';

export default function Registration({ value }) {
  return (
    <Row className="mb-3">
      <h6> Role Mapping By Email </h6>
      <p className="text-muted"> Map the user to a role using their email.Must be in the format: role1=email1, role2=email2  </p>
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
