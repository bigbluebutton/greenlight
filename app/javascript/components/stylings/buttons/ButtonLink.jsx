import { useNavigate } from 'react-router-dom';
import Button from 'react-bootstrap/Button';
import React, { useCallback } from 'react';
import PropTypes from 'prop-types';

export default function ButtonLink(props) {
  const navigate = useNavigate();
  const { to } = props;
  const handleClick = useCallback(() => { navigate(to); }, [to]);

  return (
    <Button
      onClick={handleClick}
    />
  );
}

ButtonLink.propTypes = {
  to: PropTypes.string.isRequired,
};
