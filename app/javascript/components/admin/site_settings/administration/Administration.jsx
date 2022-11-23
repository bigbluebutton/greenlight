import React from 'react';
import { Row } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import LinksForm from './LinksForm';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';

export default function Administration() {
  const { t } = useTranslation();
  const { data: siteSettings } = useSiteSettings(['Terms', 'PrivacyPolicy']);

  return (
    <>
      <Row className="mb-4">
        <h6> { t('admin.site_settings.administration.terms') } </h6>
        <p className="text-muted"> { t('admin.site_settings.administration.change_term_links') } </p>
        <LinksForm
          id="termsForm"
          mutation={() => useUpdateSiteSetting('Terms')}
          value={siteSettings?.Terms}
        />
      </Row>
      <Row>
        <h6> { t('admin.site_settings.administration.privacy') } </h6>
        <p className="text-muted"> { t('admin.site_settings.administration.change_privacy_link') } </p>
        <LinksForm
          id="privacyForm"
          mutation={() => useUpdateSiteSetting('PrivacyPolicy')}
          value={siteSettings?.PrivacyPolicy}
        />
      </Row>
    </>
  );
}
