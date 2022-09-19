import React from 'react';
import PropTypes from 'prop-types';
import { Row } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import LinksForm from './LinksForm';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';

export default function Administration({ terms, privacy }) {
  const { t } = useTranslation();

  return (
    <>
      <Row className="mb-4">
        <h6> { t('admin.site_settings.administration.terms') } </h6>
        <p className="text-muted"> { t('admin.site_settings.administration.change_term_links') } </p>
        <LinksForm
          id="termsForm"
          mutation={() => useUpdateSiteSetting('Terms')}
          value={terms}
        />
      </Row>
      <Row>
        <h6> { t('admin.site_settings.administration.privacy') } </h6>
        <p className="text-muted"> { t('admin.site_settings.administration.change_privacy_links') } </p>
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
