import React from 'react';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';
import BrandColorForm from './forms/BrandColorForm';

export default function BrandColor() {
  const { data: siteSettings } = useSiteSettings();

  return (
    <>
      <h6>Brand Color</h6>
      <BrandColorForm name="PrimaryColor" color={siteSettings?.PrimaryColor} btnVariant="brand" />
      <BrandColorForm name="PrimaryColorLight" color={siteSettings?.PrimaryColorLight} btnVariant="brand-light" />
    </>
  );
}
