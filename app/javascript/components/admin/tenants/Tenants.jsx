import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Button,
  Col, Container, Row, Stack, Tab,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { PlusIcon } from '@heroicons/react/24/outline';
import AdminNavSideBar from '../AdminNavSideBar';
import SearchBar from '../../shared_components/search/SearchBar';
import Modal from '../../shared_components/modals/Modal';
import CreateTenantForm from './forms/CreateTenantForm';

export default function Tenants() {
  const { t } = useTranslation();

  const [searchInput, setSearchInput] = useState();

  return (
    <div id="admin-panel" className="pb-3">
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
