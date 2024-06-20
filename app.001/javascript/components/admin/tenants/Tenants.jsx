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
import { Navigate } from 'react-router-dom';
import {
  Button,
  Col, Container, Row, Stack, Tab,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { PlusIcon } from '@heroicons/react/24/outline';
import AdminNavSideBar from '../AdminNavSideBar';
import SearchBar from '../../shared_components/search/SearchBar';
import useTenants from '../../../hooks/queries/admin/tenants/useTenants';
import NoSearchResults from '../../shared_components/search/NoSearchResults';
import TenantsTable from './TenantsTable';
import Modal from '../../shared_components/modals/Modal';
import CreateTenantForm from './forms/CreateTenantForm';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function Tenants() {
  const { t } = useTranslation();
  const [page, setPage] = useState();
  const currentUser = useAuth();

  if (!currentUser.isSuperAdmin) {
    return <Navigate to="/" />;
  }

  const [searchInput, setSearchInput] = useState();
  const { data: tenants, isLoading } = useTenants({ search: searchInput, page });

  return (
    <div id="admin-panel" className="pb-4">
      <h3 className="py-5">{ t('admin.admin_panel') }</h3>
      <Card className="border-0 card-shadow">
        <Tab.Container activeKey="tenants">
          <Row>
            <Col className="pe-0" sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col className="ps-0" sm={9}>
              <Tab.Content className="p-0">
                <Container className="admin-table p-0">
                  <div className="ps-4 pe-4 pt-4">
                    <h3>Manage Tenants</h3>
                  </div>
                  <div className="p-4">
                    <Stack direction="horizontal" className="mb-4">
                      <div>
                        <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
                      </div>
                      <div className="ms-auto">
                        <Modal
                          modalButton={
                            <Button variant="brand"><PlusIcon className="hi-s me-1" />New Tenant</Button>
                          }
                          title="Create New Tenant"
                          body={<CreateTenantForm />}
                        />
                      </div>
                    </Stack>
                    {
                      (searchInput && tenants?.data.length === 0)
                        ? (
                          <div className="mt-5">
                            <NoSearchResults text="No Tenant Found" searchInput={searchInput} />
                          </div>
                        ) : (
                          <TenantsTable isLoading={isLoading} tenants={tenants?.data} pagination={tenants?.meta} setPage={setPage} />
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
