import React from 'react';
import { Pagination as PaginationSematicUi } from 'semantic-ui-react';
import PropTypes from 'prop-types';
import PaginationButton from './PaginationPrevButton';

export default function Pagination({ page, totalPages, setPage }) {
  const handlePage = (e, { activePage }) => {
    const gotopage = { activePage };
    const pagenum = gotopage.activePage;
    setPage(pagenum);
  };

  if (totalPages > 0) {
    return (
      <div className="pagination-wrapper">
        <PaginationSematicUi
          secondary
          boundaryRange={3}
          defaultActivePage={page}
          totalPages={totalPages}
          onPageChange={handlePage}
          firstItem={null}
          lastItem={null}
          siblingRange={1}
          prevItem={{
            content: <PaginationButton direction="Previous" />,
            icon: true,
          }}
          nextItem={{
            content: <PaginationButton direction="Next" />,
            icon: true,
          }}
        />
      </div>
    );
  }

  return null;
}

Pagination.propTypes = {
  page: PropTypes.number.isRequired,
  totalPages: PropTypes.number.isRequired,
  setPage: PropTypes.func.isRequired,
};
