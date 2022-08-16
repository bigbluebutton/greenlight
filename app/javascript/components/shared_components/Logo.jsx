import React from 'react';
import Image from 'react-bootstrap/Image';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Logo() {
  const { data: brandingImage } = useSiteSetting('BrandingImage');

  return (
    <Image
      src={brandingImage}
      className="brand-image"
      alt="CompanyLogo"
    />
  );
}
