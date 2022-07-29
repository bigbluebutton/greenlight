import React from 'react';
import { Container } from 'react-bootstrap';
import { Pagination } from 'semantic-ui-react';
import PropTypes from 'prop-types';

export default function Pagy({ page, totalPages, setPage }) {
  const handlePage = (e, { activePage }) => {
    const gotopage = { activePage };
    const pagenum = gotopage.activePage;
    setPage(pagenum);
  };

  return (
    <Container className="text-center">
      <Pagination
        defaultActivePage={page}
        totalPages={totalPages}
        onPageChange={handlePage}
        firstItem={null}
        lastItem={null}
        pointing
        secondary
      />
    </Container>
  );
}

Pagy.propTypes = {
  page: PropTypes.number.isRequired,
  totalPages: PropTypes.number.isRequired,
  setPage: PropTypes.func.isRequired,
};
