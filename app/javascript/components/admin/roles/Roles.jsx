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
    <div id="admin-panel" className="pb-3">
      <h3 className="py-5"> { t('admin.admin_panel') } </h3>
      <Card className="border-0 shadow-sm">
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
                            <NoSearchResults name={t('admin.roles.roles')} searchInput={searchInput} />
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
