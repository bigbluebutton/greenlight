import React from 'react';
import { Pagination as PaginationSemanticUi } from 'semantic-ui-react';
import PropTypes from 'prop-types';
import PaginationButton from './PaginationButton';

export default function Pagination({
  page, totalPages, setPage,
}) {
  const handlePage = (e, { activePage }) => setPage(activePage);

  const disabledPrevious = () => (page === 1);

  const disabledNext = () => (page === totalPages);

  if (totalPages > 1) {
    return (
      <div className="semantic-ui-pagination pagination-wrapper">
        <PaginationSemanticUi
          secondary
          defaultActivePage={page}
          totalPages={totalPages}
          onPageChange={handlePage}
          firstItem={null}
          lastItem={null}
          prevItem={
          {
            disabled: disabledPrevious(),
            content: <PaginationButton page={page} totalPages={totalPages} direction="Previous" />,
            icon: true,
          }
        }
          nextItem={{
            disabled: disabledNext(),
            content: <PaginationButton page={page} totalPages={totalPages} direction="Next" />,
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
