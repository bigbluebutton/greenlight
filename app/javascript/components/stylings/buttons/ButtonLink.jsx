import { useNavigate } from 'react-router';
import Button from 'react-bootstrap/Button';
import React, { useCallback } from 'react';

export default function ButtonLink(props) {
  const navigate = useNavigate();
  const { to, ...rest } = props;
  const handleClick = useCallback(() => { navigate(to); }, [to]);

  return (
    <Button
      {...rest}
      onClick={handleClick}
    />
  );
}
