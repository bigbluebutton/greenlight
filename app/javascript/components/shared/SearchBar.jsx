import React from 'react';
import { Form } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function SearchBar({ id, setSearch }) {
  return (
    <Form>
      <Form.Group>
        <Form.Control
          id={id}
          className="search-bar rounded border"
          placeholder="Search"
          type="search"
          onKeyPress={(e) => (
            e.key === 'Enter' && e.preventDefault()
          )}
          onChange={(event) => setSearch(event.target.value)}
        />
      </Form.Group>
    </Form>
  );
}

SearchBar.propTypes = {
  id: PropTypes.string.isRequired,
  setSearch: PropTypes.func.isRequired,
};
