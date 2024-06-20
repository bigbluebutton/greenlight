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

import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Table, Dropdown } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { CheckIcon, XMarkIcon, ArchiveBoxXMarkIcon } from '@heroicons/react/24/solid';
import { EllipsisVerticalIcon } from '@heroicons/react/24/outline';
import SortBy from '../../shared_components/search/SortBy';
import useInvitations from '../../../hooks/queries/admin/manage_users/useInvitations';
import Pagination from '../../shared_components/Pagination';
import NoSearchResults from '../../shared_components/search/NoSearchResults';
import EmptyUsersList from './EmptyUsersList';
import { localizeDateTimeString } from '../../../helpers/DateTimeHelper';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import ManageUsersInvitedRowPlaceHolder from './ManageUsersInvitedRowPlaceHolder';
import useRevokeUserInvite from '../../../hooks/mutations/admin/manage_users/useRevokeUserInvite';

export default function InvitedUsersTable({ searchInput }) {
  const { t } = useTranslation();
  const [page, setPage] = useState();
  const { isLoading, data: invitations } = useInvitations(searchInput, page);
  const currentUser = useAuth();
  const revokeUserInvite = useRevokeUserInvite();

  if (!searchInput && invitations?.data?.length === 0) {
    return <EmptyUsersList text={t('admin.manage_users.empty_invited_users')} subtext={t('admin.manage_users.empty_invited_users_subtext')} />;
  }

  return (
    <div>
      {
      (!isLoading && searchInput && invitations?.data.length === 0)
        ? (
          <div className="mt-5">
            <NoSearchResults text={t('user.search_not_found')} searchInput={searchInput} />
          </div>
        ) : (
          <div id="admin-table">
            <Table className="table-bordered border border-2 mb-0" hover responsive>
              <thead>
                <tr className="text-muted small">
                  <th className="fw-normal border-end-0">{ t('user.email_address') }<SortBy fieldName="email" /></th>
                  <th className="fw-normal border-0">{ t('admin.manage_users.invited.time_sent') }</th>
                  <th className="fw-normal border-0">{ t('admin.manage_users.invited.valid') }</th>
                </tr>
              </thead>
              <tbody className="border-top-0">
                {
                isLoading
                  ? (
                  // eslint-disable-next-line react/no-array-index-key
                    [...Array(5)].map((val, idx) => <ManageUsersInvitedRowPlaceHolder key={idx} />)
                  )
                  : (
                    invitations?.data?.length
                    && (
                      invitations?.data?.map((invitation) => (
                        <tr key={invitation.email} className="align-middle text-muted">
                          <td className="text-dark border-0">{invitation.email}</td>
                          <td className="text-dark border-0">{localizeDateTimeString(invitation.updated_at, currentUser?.language)}</td>
                          <td className="text-dark border-0">
                            { invitation.valid ? <CheckIcon className="text-success hi-s" /> : <XMarkIcon className="text-danger hi-s" />}
                          </td>
                          <td className="text-dark border-0">
                            <Dropdown className="float-end cursor-pointer">
                              <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />
                              <Dropdown.Menu>
                                <Dropdown.Item onClick={() => revokeUserInvite.mutate(invitation.id)}>
                                  <ArchiveBoxXMarkIcon className="hi-s me-2" />
                                  {t('admin.manage_users.invited.revoke')}
                                </Dropdown.Item>
                              </Dropdown.Menu>
                            </Dropdown>
                          </td>
                        </tr>
                      ))
                    )
                  )
}
              </tbody>
              { invitations?.meta && (
                <Pagination
                  page={invitations?.meta?.page}
                  totalPages={invitations?.meta?.pages}
                  setPage={setPage}
                />
              ) }
            </Table>
          </div>
        )
        }
    </div>
  );
}

InvitedUsersTable.propTypes = {
  searchInput: PropTypes.string,
};

InvitedUsersTable.defaultProps = {
  searchInput: '',
};
