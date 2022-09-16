import React from 'react';
import { Stack } from 'react-bootstrap';
import BrandColorPopover from './BrandColorPopover';
import useSiteSetting from '../../../../hooks/queries/site_settings/useSiteSetting';

export default function BrandColor() {
  const { data: brandColor } = useSiteSetting('PrimaryColor');
  const { data: brandColorLight } = useSiteSetting('PrimaryColorLight');

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
