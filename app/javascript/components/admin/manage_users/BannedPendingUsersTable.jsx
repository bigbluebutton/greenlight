import React from 'react';
import { Table, Dropdown } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { EllipsisVerticalIcon } from '@heroicons/react/24/outline';
import PropTypes from 'prop-types';
import BannedPendingRow from './BannedPendingRow';
import SortBy from '../../shared_components/search/SortBy';

export default function BannedPendingUsersTable({ users }) {
  const { t } = useTranslation();

  return (
    <div id="admin-table">
      <Table className="table-bordered border border-2 mb-0" hover>
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal border-end-0">{ t('user.name') }<SortBy fieldName="name" /></th>
            <th className="fw-normal border-0">{ t('user.email_address') }</th>
            <th className="fw-normal border-0">{ t('created_at') } </th>
          </tr>
        </thead>
        <tbody className="border-top-0">
          {users?.length
            ? (
              users?.map((user) => (
                <BannedPendingRow key={user.id} user={user}>
                  <Dropdown className="float-end cursor-pointer">
                    <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />

                    {/* <Dropdown.Menu>
                      <Dropdown.Item onClick={() => updateUserStatus.mutate({ id: user.id, status: 'active' })}>
                        <CheckCircleIcon className="hi-s me-2" />
                        Unban
                      </Dropdown.Item>
                    </Dropdown.Menu> */}
                  </Dropdown>
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
};
