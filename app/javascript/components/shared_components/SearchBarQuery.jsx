import React from 'react';
import PropTypes from 'prop-types';

export default function SearchBarQuery({ setInput }) {
  const onChangeHandler = (event) => {
    setInput(event.target.value);
  };

  return (
    <input
      className="search-bar rounded border form-control"
      placeholder="Search"
      type="search"
      onChange={onChangeHandler}
    />
  );
}

SearchBarQuery.propTypes = {
  setInput: PropTypes.func.isRequired,
};
