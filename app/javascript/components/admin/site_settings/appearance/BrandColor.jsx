import React from 'react';
import { Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import BrandColorPopover from './BrandColorPopover';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';

export default function BrandColor() {
  const { t } = useTranslation();
  const { data: colors } = useSiteSettings(['PrimaryColor', 'PrimaryColorLight']);

  return (
    <div className="mb-3">
      <h5> Brand Color </h5>
      <Stack direction="horizontal">
        <BrandColorPopover
          name="PrimaryColor"
          btnName={t('admin.site_settings.appearance.regular')}
          btnVariant="brand"
          initialColor={colors?.PrimaryColor}
        />
        <BrandColorPopover
          name="PrimaryColorLight"
          btnName={t('admin.site_settings.appearance.lighten')}
          btnVariant="brand-light"
          initialColor={colors?.PrimaryColorLight}
        />
      </Stack>
    </div>
  );
}
