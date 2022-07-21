import React from 'react';
import PropTypes from 'prop-types';
import { Container, Row } from 'react-bootstrap';
import useUpdateSiteSetting from '../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';
import RegistrationForm from '../../forms/admin/RegistrationForm';

export default function Registration({ value }) {
  return (
    <Container className="w-75 mt-2 ms-0">
      <Row className="mb-3">
        <Row> <h6> Role Mapping By Email </h6> </Row>
        <Row> <p className="text-muted"> Map the user to a role using their email.Must be in the format: role1=email1, role2=email2  </p> </Row>
        <Row>
          <RegistrationForm
            mutation={() => useUpdateSiteSetting('RoleMapping')}
            value={value}
          />
        </Row>
      </Row>
    </Container>
  );
}

Registration.defaultProps = {
  value: '',
};

Registration.propTypes = {
  value: PropTypes.string,
};
