import React from 'react';
import PropTypes from 'prop-types';

export default function SearchBar({ setSearch }) {
  return (
    <input
      className="search-bar rounded border form-control"
      placeholder="Search"
      type="search"
      onKeyPress={(e) => (
        e.key === 'Enter' && e.preventDefault()
      )}
      onChange={(event) => setSearch(event.target.value)}
    />
  );
}

SearchBar.propTypes = {
  setSearch: PropTypes.func.isRequired,
};
