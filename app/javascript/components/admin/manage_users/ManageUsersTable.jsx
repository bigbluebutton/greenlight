import React from 'react';
import { Table } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import ManageUserRow from './ManageUserRow';
import SortBy from '../../shared_components/search/SortBy';
import Pagination from '../../shared_components/Pagination';

export default function ManageUsersTable({ users, setPage }) {
  const { t } = useTranslation();

  return (
    <Table className="table-bordered border border-2 mb-0" hover responsive>
      <thead>
        <tr className="text-muted small">
          <th className="fw-normal border-end-0">{ t('user.name') }<SortBy fieldName="name" /></th>
          <th className="fw-normal border-0">{ t('user.email_address') }</th>
          <th className="fw-normal border-0">{ t('user.profile.role') }<SortBy fieldName="roles.name" /></th>
          <th className="border-start-0" aria-label="options" />
        </tr>
      </thead>
      <tbody className="border-top-0">
        {users?.data?.length
          ? (
            users?.data?.map((user) => <ManageUserRow key={user.id} user={user} />)
          )
          : (
            <tr>
              <td className="fw-bold" colSpan="6">
                { t('user.no_user_found') }
              </td>
            </tr>
          )}
      </tbody>
      { (users?.meta?.pages > 1)
        && (
          <tr>
            <td colSpan={12}>
              <Pagination
                page={users?.meta?.page}
                totalPages={users?.meta?.pages}
                setPage={setPage}
              />
            </td>
          </tr>
        )
      }
    </Table>
  );
}

ManageUsersTable.defaultProps = {
  users: [],
};

ManageUsersTable.propTypes = {
  users: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.shape({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      color: PropTypes.string.isRequired,
    }).isRequired,
  })),
};
