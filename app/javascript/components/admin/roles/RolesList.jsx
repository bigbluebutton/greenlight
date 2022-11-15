import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import RoleRow from './RoleRow';
import SortBy from '../../shared_components/search/SortBy';
import Spinner from '../../shared_components/utilities/Spinner';

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
          (isLoading && (
            <tr>
              <td>
                <Spinner />
              </td>
            </tr>
          )) || (
            roles?.length ? (roles?.map((role) => <RoleRow key={role.id} role={role} />))
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
