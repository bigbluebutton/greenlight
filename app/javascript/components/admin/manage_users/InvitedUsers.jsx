import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { CheckIcon, XMarkIcon } from '@heroicons/react/24/solid';
import SortBy from '../../shared_components/search/SortBy';
import useInvitations from '../../../hooks/queries/admin/manage_users/useInvitations';
import Pagination from '../../shared_components/Pagination';
import NoSearchResults from '../../shared_components/search/NoSearchResults';
import EmptyUsersList from './EmptyUsersList';
import { localizeDateTimeString } from '../../../helpers/DateTimeHelper';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import ManageUsersInvitedRowPlaceHolder from './ManageUsersInvitedRowPlaceHolder';

export default function InvitedUsers({ searchInput }) {
  const { t } = useTranslation();
  const [page, setPage] = useState();
  const { isLoading, data: invitations } = useInvitations(searchInput, page);
  const currentUser = useAuth();

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
                        </tr>
                      ))
                    )
                  )
}
              </tbody>
            </Table>
            <div className="pagination-wrapper">
              { invitations?.meta && (
              <Pagination
                page={invitations?.meta?.page}
                totalPages={invitations?.meta?.pages}
                setPage={setPage}
              />
              ) }
            </div>
          </div>

        )
        }
    </div>
  );
}

InvitedUsers.propTypes = {
  searchInput: PropTypes.string,
};

InvitedUsers.defaultProps = {
  searchInput: '',
};
