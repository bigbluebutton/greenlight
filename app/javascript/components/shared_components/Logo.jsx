import React from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import { useNavigate } from 'react-router-dom';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Logo({ size }) {
  const { isLoading, data: brandingImage } = useSiteSetting('BrandingImage');
  const navigate = useNavigate();

  // Logo can be small or regular size
  const sizeClass = size === 'small'
    ? 'mb-4 small-logo cursor-pointer'
    : 'mb-4 logo cursor-pointer position-absolute bottom-0 mx-auto start-0 end-0 text-center';
  // Small Logo is used in Header only and does not require a wrapper
  const sizeWrapperClass = !size ? 'logo-wrapper position-relative d-block mx-auto' : undefined;

  if (isLoading) return <div className={sizeWrapperClass} />;

  return (
    <div className={sizeWrapperClass}>
      <Image
        src={brandingImage}
        className={sizeClass}
        alt="CompanyLogo"
        onClick={() => { navigate('/'); }}
      />
    </div>
  );
}

Logo.propTypes = {
  size: PropTypes.string,
};

Logo.defaultProps = {
  size: '',
};
