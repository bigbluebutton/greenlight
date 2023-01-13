import React from 'react';
import Image from 'react-bootstrap/Image';
import PropTypes from 'prop-types';
import { useNavigate } from 'react-router-dom';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';

export default function Logo({ size }) {
  const { isLoading, data: brandingImage } = useSiteSetting('BrandingImage');
  const navigate = useNavigate();
  const sizeClass = `${size}-logo`;

  if (isLoading) return null;

  return (
    <Image
      src={brandingImage}
      className={`cursor-pointer ${sizeClass}`}
      alt="CompanyLogo"
      onClick={() => { navigate('/'); }}
    />
  );
}

Logo.propTypes = {
  size: PropTypes.oneOf(['small', 'medium', 'large']),
};

Logo.defaultProps = {
  size: 'small',
};
