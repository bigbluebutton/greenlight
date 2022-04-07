import { useNavigate } from 'react-router-dom';
import Button from 'react-bootstrap/Button';
import React, { useCallback } from 'react';
import PropTypes from 'prop-types';

export default function ButtonLink(props) {
  const navigate = useNavigate();
  const {
    to, className, variant, children,
  } = props;
  const handleClick = useCallback(() => { navigate(to); }, [to]);

  return (
    <Button
      onClick={handleClick}
      className={className}
      variant={variant}
    >
      {children}
    </Button>
  );
}

ButtonLink.defaultProps = {
  className: '',
  variant: 'primary',
};

ButtonLink.propTypes = {
  to: PropTypes.string.isRequired,
  className: PropTypes.string,
  variant: PropTypes.string,
  children: PropTypes.element.isRequired,
};
