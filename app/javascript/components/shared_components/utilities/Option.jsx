import React, { useCallback, useContext } from 'react';
import PropTypes from 'prop-types';
import { Dropdown } from 'react-bootstrap';
import { ACTIONS, SelectContext } from './Select';

export default function Option({ children: title, value }) {
  const { selected, dispatch } = useContext(SelectContext);
  const handleClick = useCallback(() => { dispatch({ type: ACTIONS.SELECT, msg: { title, value } }); }, [dispatch]);
  const isActive = selected.title === title && selected.value === value;

  return (
    <Dropdown.Item onClick={handleClick} active={isActive}> {title} </Dropdown.Item>
  );
}

Option.propTypes = {
  children: PropTypes.string.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number, PropTypes.bool]).isRequired,
};
