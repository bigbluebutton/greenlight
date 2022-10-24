import React, { useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash.debounce';

export default function SearchBarQuery({ setInput }) {
  const onChangeHandler = (event) => {
    setInput(event.target.value);
  };

  const debouncedOnChangeHandler = useMemo(
    () => debounce(onChangeHandler, 300),
    [],
  );

  useEffect(() => () => {
    debouncedOnChangeHandler.cancel();
  }, []);

  return (
    <input
      className="search-bar rounded border form-control"
      placeholder="Search"
      type="search"
      onChange={debouncedOnChangeHandler}
    />
  );
}

SearchBarQuery.propTypes = {
  setInput: PropTypes.func.isRequired,
};
