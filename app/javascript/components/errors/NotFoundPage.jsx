import React from 'react';
import {
  Card, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import Logo from '../shared_components/Logo';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function NotFoundPage() {
  const { t } = useTranslation();

  // Needed for Route Errors
  const { data: brandColor } = useSiteSetting('PrimaryColor');
  document.documentElement.style.setProperty('--brand-color', brandColor);

  return (
    <div className="pt-lg-5">
      <div className="text-center pb-4">
        <Logo />
      </div>
      <Card className="col-md-3 mx-auto p-4 border-0 card-shadow">
        <Stack direction="vertical" className="py-3">
          <h1><strong>404</strong></h1>
          <h3>{t('not_found_error_page.title')}</h3>
        </Stack>
        <span className="mb-3">{ t('not_found_error_page.message') }</span>
        <ButtonLink to="/" variant="brand" className="btn btn-lg mt-2">
          {t('return_home')}
        </ButtonLink>
      </Card>
    </div>
  );
}
