import React, { useState } from 'react';
import {
  Col, Container, Row, Tab, Card, Stack,
} from 'react-bootstrap';
import AdminNavSideBar from './shared/AdminNavSideBar';
import RolesList from './roles/RolesList';
import SearchBarQuery from '../shared/SearchBarQuery';
import useRoles from '../../hooks/queries/admin/roles/useRoles';
import CreateRoleModal from '../shared/modals/CreateRoleModal';

export default function Roles() {
  const [input, setInput] = useState();
  const { data: roles, isLoading } = useRoles(input);

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="roles">
          <Row>
            <Col sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Container>
                  <Row className="my-1"><h3>Roles</h3></Row>
                  <Row><hr className="w-100 mx-0" /></Row>
                  <Row className="my-2">
                    <Stack direction="horizontal" className="w-100">
                      <div>
                        <SearchBarQuery setInput={setInput} />
                      </div>
                      <CreateRoleModal />
                    </Stack>

                  </Row>
                  <Row className="my-2">
                    <Col><RolesList isLoading={isLoading} roles={roles} /></Col>
                  </Row>
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
