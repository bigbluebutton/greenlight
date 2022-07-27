import React from 'react';
import { Stack } from 'react-bootstrap';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';
import BrandColorPopover from './BrandColorPopover';

export default function BrandColor() {
  const { data: siteSettings } = useSiteSettings();

  const brandDefaultColors = [
    '#B80000', '#DB3E00', '#FCCB00', '#008B02', '#006B76', '#1273DE', '#004DCF', '#5300EB',
  ];

  const brandLightDefaultColors = [
    '#EB9694', '#FAD0C3', '#FEF3BD', '#C1E1C5', '#BEDADC', '#C4DEF6', '#BED3F3', '#D4C4FB',
  ];

  return (
    <>
      <h6> Brand Color </h6>
      <Stack direction="horizontal">
        <BrandColorPopover
          name="PrimaryColor"
          btnName="Regular"
          btnVariant="brand"
          currentColor={siteSettings?.PrimaryColor}
          defaultColors={brandDefaultColors}
        />
        <BrandColorPopover
          name="PrimaryColorLight"
          btnName="Lighten"
          btnVariant="brand-light"
          currentColor={siteSettings?.PrimaryColorLight}
          defaultColors={brandLightDefaultColors}
        />
      </Stack>
    </>
  );
}
