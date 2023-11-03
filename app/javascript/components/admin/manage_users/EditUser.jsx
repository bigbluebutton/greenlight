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
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Stack, Container,
} from 'react-bootstrap';
import { useParams, useNavigate, Navigate } from 'react-router-dom';
import { ArrowLeftCircleIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import AdminNavSideBar from '../AdminNavSideBar';
import AccountInfo from '../../users/user/AccountInfo';
import useUser from '../../../hooks/queries/users/useUser';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function EditUser() {
  const { t } = useTranslation();
  const { userId } = useParams();
  const { isLoading, data: user } = useUser(userId);
  const navigate = useNavigate();
  const currentUser = useAuth();
  // Todo: Use PermissionChecker.
  if (currentUser.permissions?.ManageUsers !== 'true') {
    return <Navigate to="/404" />;
  }

  return (
    <div id="admin-panel" className="pb-4">
      <h3 className="py-5"> { t('admin.admin_panel') } </h3>
      <Card className="border-0 card-shadow">
        <Tab.Container activekey="users">
          <Container>
            <Row>
              <Col className="px-0" sm={3}>
                <div id="admin-sidebar">
                  <AdminNavSideBar />
                </div>
              </Col>
              <Col className="px-0" sm={9}>
                <Tab.Content className="ps-0">
                  <Container className="p-0">
                    <div className="p-4 border-bottom">
                      <div className="d-inline-block">
                        <h3>{ t('admin.manage_users.edit_user')}</h3>
                      </div>
                      <Stack
                        className="d-inline-block float-end cursor-pointer pe-2 pt-2 text-muted back-button"
                        aria-hidden="true"
                        onClick={() => navigate('/admin/users')}
                      >
                        <ArrowLeftCircleIcon className="hi-s" /> { t('back') }
                      </Stack>
                    </div>
                    {!isLoading && (
                      <div className="p-4">
                        <AccountInfo user={user} />
                      </div>
                    )}
                  </Container>
                </Tab.Content>
              </Col>
            </Row>
          </Container>
        </Tab.Container>
      </Card>
    </div>
  );
}
