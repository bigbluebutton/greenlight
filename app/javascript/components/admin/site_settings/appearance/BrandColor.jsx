import React from 'react';
import { Stack } from 'react-bootstrap';
import BrandColorPopover from './BrandColorPopover';
import useSiteSettingAsync from '../../../../hooks/queries/site_settings/useSiteSettingAsync';

export default function BrandColor() {
  const { data: brandColor } = useSiteSettingAsync('PrimaryColor');
  const { data: brandColorLight } = useSiteSettingAsync('PrimaryColorLight');

  return (
    <div className="mb-3">
      <h5> Brand Color </h5>
      <Stack direction="horizontal">
        <BrandColorPopover
          name="PrimaryColor"
          btnName="Regular"
          btnVariant="brand"
          initialColor={brandColor}
        />
        <BrandColorPopover
          name="PrimaryColorLight"
          btnName="Lighten"
          btnVariant="brand-light"
          initialColor={brandColorLight}
        />
      </Stack>
    </div>
  );
}
