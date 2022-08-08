import React from 'react';
import PropTypes from 'prop-types';
import { Row } from 'react-bootstrap';
import LinksForm from '../../forms/admin/LinksForm';
import useUpdateSiteSetting from '../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';

export default function Administration({ terms, privacy }) {
  return (
    <>
      <Row className="mb-4">
        <h6> Terms </h6>
        <p className="text-muted"> Change the Terms Link that appears in the bottom of the page </p>
        <LinksForm
          id="termsForm"
          mutation={() => useUpdateSiteSetting('Terms')}
          value={terms}
        />
      </Row>
      <Row>
        <h6> Privacy </h6>
        <p className="text-muted"> Change the Privacy Link that appears in the bottom of the page </p>
        <LinksForm
          id="privacyForm"
          mutation={() => useUpdateSiteSetting('PrivacyPolicy')}
          value={privacy}
        />
      </Row>
    </>
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
