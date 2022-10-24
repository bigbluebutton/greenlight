import React, { useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import debounce from 'lodash.debounce';
import { useTranslation } from 'react-i18next';

export default function SearchBar({ searchInput, setSearchInput }) {
  const { t } = useTranslation();

  const onChangeHandler = (event) => {
    setSearchInput(event.target.value);
  };

  const debouncedOnChangeHandler = useMemo(
    () => debounce(onChangeHandler, 300),
    [],
  );

  useEffect(() => () => {
    debouncedOnChangeHandler.cancel();
  }, [searchInput]);

  return (
    <input
      className="search-bar rounded border form-control"
      placeholder={t('search')}
      type="search"
      onChange={debouncedOnChangeHandler}
    />
  );
}

SearchBar.propTypes = {
  searchInput: PropTypes.string,
  setSearchInput: PropTypes.func.isRequired,
};

SearchBar.defaultProps = {
  searchInput: '',
};
