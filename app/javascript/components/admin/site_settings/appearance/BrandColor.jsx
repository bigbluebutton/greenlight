import React from 'react';
import { Stack } from 'react-bootstrap';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';
import BrandColorPopover from './BrandColorPopover';

export default function BrandColor() {
  const { data: siteSettings } = useSiteSettings();

  return (
    <>
      <h5> Brand Color </h5>
      <Stack direction="horizontal">
        <BrandColorPopover
          name="PrimaryColor"
          btnName="Regular"
          btnVariant="brand"
          initialColor={siteSettings?.PrimaryColor}
        />
        <BrandColorPopover
          name="PrimaryColorLight"
          btnName="Lighten"
          btnVariant="brand-light"
          initialColor={siteSettings?.PrimaryColorLight}
        />
      </Stack>
    </>
  );
}
