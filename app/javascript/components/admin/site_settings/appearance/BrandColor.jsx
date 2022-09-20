import React from 'react';
import { Stack } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import BrandColorPopover from './BrandColorPopover';
import useSiteSetting from '../../../../hooks/queries/site_settings/useSiteSetting';

export default function BrandColor() {
  const { t } = useTranslation();
  const { data: brandColor } = useSiteSetting('PrimaryColor');
  const { data: brandColorLight } = useSiteSetting('PrimaryColorLight');

  return (
    <div className="mb-3">
      <h5> Brand Color </h5>
      <Stack direction="horizontal">
        <BrandColorPopover
          name="PrimaryColor"
          btnName={t('admin.site_settings.appearance.regular')}
          btnVariant="brand"
          initialColor={brandColor}
        />
        <BrandColorPopover
          name="PrimaryColorLight"
          btnName={t('admin.site_settings.appearance.lighten')}
          btnVariant="brand-light"
          initialColor={brandColorLight}
        />
      </Stack>
    </div>
  );
}
