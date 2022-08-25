import React, { useState } from 'react';
import {
  Col, Container, Row, Tab, Card, Stack,
} from 'react-bootstrap';
import AdminNavSideBar from '../AdminNavSideBar';
import RolesList from './RolesList';
import SearchBarQuery from '../../shared_components/search/SearchBarQuery';
import useRoles from '../../../hooks/queries/admin/roles/useRoles';
import CreateRoleModal from '../../shared_components/modals/CreateRoleModal';

export default function Roles() {
  const [input, setInput] = useState();
  const { data: roles, isLoading } = useRoles(input);

  return (
    <div id="admin-panel">
      <h3 className="py-5"> Administrator Panel </h3>
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
                <Container className="p-0">
                  <div className="p-4 border-bottom">
                    <h3> Manage Roles </h3>
                  </div>
                  <div className="p-4">
                    <Stack direction="horizontal" className="mb-4">
                      <div>
                        <SearchBarQuery setInput={setInput} />
                      </div>
                      <CreateRoleModal />
                    </Stack>
                    <RolesList isLoading={isLoading} roles={roles} />
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
