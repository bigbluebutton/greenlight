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
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import RoleRow from './RoleRow';
import SortBy from '../../shared_components/search/SortBy';
import RoleRowPlaceHolder from './RoleRowPlaceHolder';

export default function RolesList({ roles, isLoading }) {
  const { t } = useTranslation();

  return (
    <Table className="table-bordered border border-2 mb-0" hover responsive>
      <thead>
        <tr className="text-muted small">
          <th className="fw-normal">{ t('admin.roles.role') }<SortBy fieldName="name" /></th>
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
              roles?.length
                ? (
                  roles?.map((role) => <RoleRow key={role.id} role={role} />)
                )
                : (
                  <tr>
                    <td className="fw-bold" colSpan="6">
                      { t('admin.roles.no_role_found') }
                    </td>
                  </tr>
                )
            )
        }
      </tbody>
    </Table>
  );
}

RolesList.defaultProps = {
  roles: [],
  isLoading: false,
};

RolesList.propTypes = {
  roles: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
  })),
  isLoading: PropTypes.bool,
};
