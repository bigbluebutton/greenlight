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
import {
  Col, Container, Row, Tab, Card, Stack,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { Navigate } from 'react-router-dom';
import AdminNavSideBar from '../AdminNavSideBar';
import RolesList from './RolesList';
import SearchBar from '../../shared_components/search/SearchBar';
import useRoles from '../../../hooks/queries/admin/roles/useRoles';
import CreateRoleModal from '../../shared_components/modals/CreateRoleModal';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import NoSearchResults from '../../shared_components/search/NoSearchResults';

export default function Roles() {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState();
  const { data: roles, isLoading } = useRoles({ search: searchInput });
  const currentUser = useAuth();

  if (currentUser.permissions?.ManageRoles !== 'true') {
    return <Navigate to="/404" />;
  }

  return (
    <div id="admin-panel" className="pb-4">
      <h3 className="py-5"> { t('admin.admin_panel') } </h3>
      <Card className="border-0 card-shadow">
        <Tab.Container activeKey="roles">
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
                    <h3> { t('admin.roles.manage_roles') } </h3>
                  </div>
                  <div className="p-4">
                    <Stack direction="horizontal" className="mb-4">
                      <div>
                        <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
                      </div>
                      <CreateRoleModal />
                    </Stack>
                    {
                      (searchInput && roles?.length === 0)
                        ? (
                          <div className="mt-5">
                            <NoSearchResults text={t('admin.roles.search_not_found')} searchInput={searchInput} />
                          </div>
                        ) : (
                          <RolesList isLoading={isLoading} roles={roles} />
                        )
}
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
