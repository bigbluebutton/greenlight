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
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs, Stack, Button, Container,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { Navigate } from 'react-router-dom';
import { EnvelopeIcon, UserPlusIcon } from '@heroicons/react/24/outline';
import VerifiedUsers from './VerifiedUsers';
import AdminNavSideBar from '../AdminNavSideBar';
import Modal from '../../shared_components/modals/Modal';
import UserSignupForm from './forms/UserSignupForm';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';
import SearchBar from '../../shared_components/search/SearchBar';
import InviteUserForm from './forms/InviteUserForm';
import InvitedUsersTable from './InvitedUsersTable';
import PendingUsers from './PendingUsers';
import BannedUsers from './BannedUsers';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import useEnv from '../../../hooks/queries/env/useEnv';
import UnverifiedUsers from "./UnverifiedUsers";

export default function ManageUsers() {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState();
  const { data: registrationMethod } = useSiteSetting('RegistrationMethod');
  const currentUser = useAuth();
  const envAPI = useEnv();

  if (currentUser.permissions?.ManageUsers !== 'true') {
    return <Navigate to="/404" />;
  }

  return (
    <div id="admin-panel" className="pb-4">
      <h3 className="py-5">{t('admin.admin_panel')}</h3>
      <Card className="border-0 card-shadow">
        <Tab.Container activeKey="users">
          <Row>
            <Col className="pe-0" sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col className="ps-0" sm={9}>
              <Tab.Content className="p-0">
                <Container className="admin-table p-0">
                  <div className="p-4 border-bottom">
                    <h3>{t('admin.manage_users.manage_users')}</h3>
                  </div>
                  <div className="p-4">
                    <Stack direction="horizontal" className="mb-4">
                      <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
                      <div className="ms-auto">
                        {registrationMethod === 'invite'
                          && (
                            <Modal
                              modalButton={(
                                <Button variant="brand-outline" className="me-3">
                                  <EnvelopeIcon className="hi-s me-1" />{t('admin.manage_users.invite_user')}
                                </Button>
                              )}
                              title={t('admin.manage_users.invite_user')}
                              body={<InviteUserForm />}
                              size="md"
                            />
                          )}
                        {
                          (!envAPI.isLoading && !envAPI.data?.EXTERNAL_AUTH)
                          && (
                            <Modal
                              modalButton={
                                <Button variant="brand"><UserPlusIcon className="hi-s me-1" /> {t('admin.manage_users.add_new_user')}</Button>
                              }
                              title={t('admin.manage_users.create_new_user')}
                              body={<UserSignupForm />}
                            />
                          )
                        }

                      </div>
                    </Stack>
                    <Tabs defaultActiveKey="active" unmountOnExit>
                      <Tab eventKey="active" title={t('admin.manage_users.active')}>
                        <VerifiedUsers searchInput={searchInput} />
                      </Tab>
                      <Tab eventKey="unverified" title={t('admin.manage_users.unverified')} >
                        <UnverifiedUsers searchInput={searchInput} />
                      </Tab>
                      {registrationMethod === 'approval'
                        && (
                          <Tab eventKey="pending" title={t('admin.manage_users.pending')}>
                            <PendingUsers searchInput={searchInput} />
                          </Tab>
                        )}
                      <Tab eventKey="banned" title={t('admin.manage_users.banned')}>
                        <BannedUsers searchInput={searchInput} />
                      </Tab>
                      {registrationMethod === 'invite'
                        && (
                          <Tab eventKey="invited" title={t('admin.manage_users.invited_tab')}>
                            <InvitedUsersTable input={searchInput} />
                          </Tab>
                        )}
                    </Tabs>
                  </div>
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
