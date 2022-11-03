import React from 'react';
import { Table, Dropdown } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import PropTypes from 'prop-types';
import { CheckCircleIcon, EllipsisVerticalIcon, XCircleIcon } from '@heroicons/react/24/outline';
import BannedPendingRow from './BannedPendingRow';
import useUpdateUserStatus from '../../../hooks/mutations/admin/manage_users/useUpdateUserStatus';

// pendingTable prop is true when table is being used for pending data, false when table is being used for banned data
export default function BannedPendingUsersTable({ users, pendingTable }) {
  const { t } = useTranslation();
  const updateUserStatus = useUpdateUserStatus();

  return (
    <div id="admin-table">
      <Table className="table-bordered border border-2 mb-0" hover>
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-end-0">{ t('user.name') } </th>
            <th className="fw-normal border-0">{ t('user.email_address') } </th>
            <th className="fw-normal border-0">{ t('created_at') } </th>
          </tr>
        </thead>
        <tbody className="border-top-0">
          {users?.length
            ? (
              users?.map((user) => (
                <BannedPendingRow key={user.id} user={user}>
                  {pendingTable ? (
                    <Dropdown className="float-end cursor-pointer">
                      <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />

                      <Dropdown.Menu>
                        <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'active' })}>
                          <CheckCircleIcon className="hi-s me-2" />
                          {t('admin.manage_users.approve')}
                        </Dropdown.Item>
                        <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'banned' })}>
                          <XCircleIcon className="hi-s me-2" />
                          {t('admin.manage_users.decline')}
                        </Dropdown.Item>
                      </Dropdown.Menu>
                    </Dropdown>
                  ) : (
                    <Dropdown className="float-end cursor-pointer">
                      <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />

                      <Dropdown.Menu>
                        <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'active' })}>
                          <CheckCircleIcon className="hi-s me-2" />
                          {t('admin.manage_users.unban')}
                        </Dropdown.Item>
                      </Dropdown.Menu>
                    </Dropdown>
                  )}
                </BannedPendingRow>
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
    </div>
  );
}

BannedPendingUsersTable.defaultProps = {
  users: [],
};

BannedPendingUsersTable.propTypes = {
  users: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
  })),
  pendingTable: PropTypes.bool.isRequired,
};
