import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Container, Row, Stack, Tab,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import AdminNavSideBar from '../AdminNavSideBar';
import SearchBar from '../../shared_components/search/SearchBar';
import CreateTenantModal from './CreateTenantModal';

export default function SuperAdmin() {
  const { t } = useTranslation();

  const [searchInput, setSearchInput] = useState();

  return (
    <div id="admin-panel" className="pb-3">
      <h3 className="py-5">{ t('admin.admin_panel') }</h3>
      <Card className="border-0 card-shadow">
        <Tab.Container activeKey="super_admin">
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
                    <h3>{t('admin.tenants.manage_tenants')}</h3>
                  </div>
                  <div className="p-4">
                    <Stack direction="horizontal" className="mb-4">
                      <div>
                        <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
                      </div>
                      <CreateTenantModal />
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
