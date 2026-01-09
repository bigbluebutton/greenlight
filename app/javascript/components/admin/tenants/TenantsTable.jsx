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
import { Table } from 'react-bootstrap';
import PropTypes from 'prop-types';
import SortBy from '../../shared_components/search/SortBy';
import RoleRowPlaceHolder from '../roles/RoleRowPlaceHolder';
import TenantRow from './TenantRow';
import Pagination from '../../shared_components/Pagination';

export default function TenantsTable({
  tenants, isLoading, pagination, setPage,
}) {
  return (
    <Table className="table-bordered border border-2 mb-0" hover responsive>
      <thead>
        <tr className="text-muted small">
          <th className="fw-normal border-0">Tenant<SortBy fieldName="name" /></th>
          <th className="fw-normal border-0">Client Secret</th>
          <th className="fw-normal border-0">Region</th>
          <th className="border-start-0" aria-label="options" />
        </tr>
      </thead>
      <tbody className="border-top-0">
        {
        isLoading
          ? (
            // eslint-disable-next-line react/no-array-index-key
            [...Array(10)].map((val, idx) => <RoleRowPlaceHolder key={idx} />)
          )
          : (
            tenants?.map((tenant) => <TenantRow key={tenant.id} tenant={tenant} />)
          )
      }
      </tbody>
      { (pagination?.pages > 1)
        && (
          <tfoot>
            <tr>
              <td colSpan={12}>
                <Pagination
                  page={pagination?.page}
                  totalPages={pagination?.pages}
                  setPage={setPage}
                />
              </td>
            </tr>
          </tfoot>
        )}
    </Table>
  );
}

TenantsTable.defaultProps = {
  tenants: [],
  pagination: {
    page: 1,
    pages: 1,
  },
};

TenantsTable.propTypes = {
  tenants: PropTypes.arrayOf(PropTypes.shape({
    name: PropTypes.string,
    client_secret: PropTypes.string,
  })),
  isLoading: PropTypes.bool.isRequired,
  pagination: PropTypes.shape({
    page: PropTypes.number.isRequired,
    pages: PropTypes.number.isRequired,
  }),
  setPage: PropTypes.func.isRequired,
};
