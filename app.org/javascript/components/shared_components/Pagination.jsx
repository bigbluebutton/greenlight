// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
      <div className="semantic-ui-pagination">
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
