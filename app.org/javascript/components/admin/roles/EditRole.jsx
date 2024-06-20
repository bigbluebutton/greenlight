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

import { ArrowLeftCircleIcon } from '@heroicons/react/24/outline';
import React from 'react';
import {
  Col, Container, Row, Tab, Card, Breadcrumb, Stack,
} from 'react-bootstrap';
import { Navigate, useNavigate, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import useRole from '../../../hooks/queries/admin/roles/useRole';
import EditRoleForm from './forms/EditRoleForm';
import AdminNavSideBar from '../AdminNavSideBar';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function EditRole() {
  const { t } = useTranslation();
  const { roleId } = useParams();
  const navigate = useNavigate();
  const { data: role, isError, isLoading } = useRole(roleId);
  const currentUser = useAuth();

  if (currentUser.permissions?.ManageRoles !== 'true') {
    return <Navigate to="/404" />;
  }

  if (isError) {
    return <Navigate to="/admin/roles" replace />;
  }

  if (isLoading) return null;

  return (
    <div id="admin-panel" className="pb-4">
      <h3 className="py-5">{ t('admin.admin_panel') }</h3>
      <Card className="border-0 card-shadow">
        <Tab.Container activeKey="roles">
          <Row>
            <Col className="pe-0" sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col className="ps-0" sm={9}>
              <Tab.Content className="ps-0">
                <Container className="admin-table p-0">
                  <div className="p-4 border-bottom">
                    <Stack className="d-inline-block ">
                      <h3 className="mb-0">{ t('admin.roles.roles') }</h3>
                      <Breadcrumb id="role-breadcrumb" className="float-start small">
                        <Breadcrumb.Item className="text-link" onClick={() => navigate('/admin/roles')}>{ t('admin.roles.role') }</Breadcrumb.Item>
                        <Breadcrumb.Item active><strong>{role?.name}</strong></Breadcrumb.Item>
                      </Breadcrumb>
                    </Stack>
                    <Stack
                      className="d-inline-block float-end cursor-pointer pe-2 pt-2 text-muted back-button"
                      aria-hidden="true"
                      onClick={() => navigate('/admin/roles')}
                    >
                      <ArrowLeftCircleIcon className="hi-s" /> { t('back') }
                    </Stack>
                  </div>
                  <div className="p-4">
                    <EditRoleForm role={role} />
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
