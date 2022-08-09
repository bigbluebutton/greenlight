import React from 'react';
import { Pagination as PaginationSemanticUi } from 'semantic-ui-react';
import PropTypes from 'prop-types';
import PaginationButton from './PaginationPrevButton';

export default function Pagination({
  page, totalPages, setPage,
}) {
  const handlePage = (e, { activePage }) => setPage(activePage);

  if (totalPages > 1) {
    return (
      <div className="semantic-ui-pagination">
        <PaginationSemanticUi
          secondary
          defaultActivePage={page}
          totalPages={totalPages}
          onPageChange={handlePage}
          firstItem={null}
          lastItem={null}
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
