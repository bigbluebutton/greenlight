import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs, Stack, Button, Container,
} from 'react-bootstrap';
import ActiveUsers from './ActiveUsers';
import AdminNavSideBar from '../AdminNavSideBar';
import Modal from '../../shared_components/modals/Modal';
import UserSignupForm from './forms/UserSignupForm';
import SearchBarQuery from '../../shared_components/search/SearchBarQuery';

export default function ManageUsers() {
  const [input, setInput] = useState();
  return (
    <div id="admin-panel" className="wide-background">
      <h3 className="my-5"> Administrator Panel </h3>
      <Card className="border-0 shadow-sm">
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
                    <h3> Manage Users </h3>
                  </div>
                  <div className="p-4">
                    <Stack direction="horizontal" className="mb-4">
                      <SearchBarQuery setInput={setInput} />
                      <Modal
                        modalButton={<Button variant="brand" className="ms-auto btn">+ New User</Button>}
                        title="Create New User"
                        body={<UserSignupForm />}
                        size="lg"
                        id="shared-access-modal"
                      />
                    </Stack>
                    <Tabs defaultActiveKey="active">
                      <Tab eventKey="active" title="Active">
                        <ActiveUsers input={input} />
                      </Tab>
                      <Tab eventKey="pending" title="Pending">
                        Pending users component
                      </Tab>
                      <Tab eventKey="banned" title="Banned">
                        Banned users component
                      </Tab>
                      <Tab eventKey="deleted" title="Deleted">
                        Deleted users component
                      </Tab>
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
