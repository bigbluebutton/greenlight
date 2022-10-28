import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Dropdown, Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { CheckCircleIcon, EllipsisVerticalIcon, XCircleIcon } from '@heroicons/react/24/outline';
import Pagination from '../../shared_components/Pagination';
import usePendingUsers from '../../../hooks/queries/admin/manage_users/usePendingUsers';
import useUpdateUserStatus from '../../../hooks/mutations/admin/manage_users/useUpdateUserStatus';

export default function PendingUsers({ searchInput }) {
  const { t } = useTranslation();
  const [page, setPage] = useState();
  const { data: users } = usePendingUsers(searchInput, page);
  const updateUserStatus = useUpdateUserStatus();

  return (
    <div id="admin-table">
      <Table className="table-bordered border border-2 mb-0" hover>
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-0">{ t('user.name') }</th>
            <th className="fw-normal border-0">{ t('user.email_address') }</th>
            <th className="border-start-0" aria-label="options" />
          </tr>
        </thead>
        <tbody className="border-top-0">
          {users?.data?.length
            ? (
              users?.data?.map((user) => (
                <tr key={user.id} className="align-middle text-muted">
                  <td className="text-dark border-0">{user.name}</td>
                  <td className="text-dark border-0">{user.email}</td>
                  <td className="text-dark border-0">
                    <Dropdown className="float-end cursor-pointer">
                      <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />

                      <Dropdown.Menu>
                        <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'active' })}>
                          <CheckCircleIcon className="hi-s me-2" />
                          Approve
                        </Dropdown.Item>
                        <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'banned' })}>
                          <XCircleIcon className="hi-s me-2" />
                          Decline
                        </Dropdown.Item>
                      </Dropdown.Menu>
                    </Dropdown>
                  </td>
                </tr>
              ))
            )
            : (
              <tr>
                <td className="fw-bold">
                  { t('user.no_user_found') }
                </td>
              </tr>
            )}
        </tbody>
      </Table>
      <div className="pagination-wrapper">
        {users?.meta && (
        <Pagination
          page={users?.meta?.page}
          totalPages={users?.meta?.pages}
          setPage={setPage}
        />
        )}
      </div>
    </div>
  );
}

PendingUsers.propTypes = {
  searchInput: PropTypes.string,
};

PendingUsers.defaultProps = {
  searchInput: '',
};
