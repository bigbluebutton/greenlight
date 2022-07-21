import React from 'react';
import PropTypes from 'prop-types';
import { Container, Row } from 'react-bootstrap';
import LinksForm from '../../forms/admin/LinksForm';
import useUpdateSiteSetting from '../../../hooks/mutations/admins/site_settings/useUpdateSiteSetting';

export default function Administration({ terms, privacy }) {
  return (
    <Container className="w-75 mt-2 ms-0">
      <Row className="mb-3">
        <Row> <h6> Terms </h6> </Row>
        <Row> <p className="text-muted"> Change the Terms Link that appears in the bottom of the page </p> </Row>
        <Row>
          <LinksForm
            id="termsForm"
            mutation={() => useUpdateSiteSetting('Terms')}
            value={terms}
          />
        </Row>
      </Row>
      <Row>
        <Row> <h6> Privacy </h6> </Row>
        <Row> <p className="text-muted"> Change the Privacy Link that appears in the bottom of the page </p> </Row>
        <Row>
          <LinksForm
            id="privacyForm"
            mutation={() => useUpdateSiteSetting('PrivacyPolicy')}
            value={privacy}
          />
        </Row>
      </Row>
    </Container>
  );
}
Administration.defaultProps = {
  terms: '',
  privacy: '',
};

Administration.propTypes = {
  terms: PropTypes.string,
  privacy: PropTypes.string,
};
