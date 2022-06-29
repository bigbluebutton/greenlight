import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs, Stack, Button,
} from 'react-bootstrap';
import ActiveUsers from './users/ActiveUsers';
import AdminNavSideBar from './shared/AdminNavSideBar';
import Modal from '../shared/Modal';
import AdminSignupForm from './AdminSignupForm';
import SearchBarQuery from '../shared/SearchBarQuery';

export default function ManageUsers() {
  const [input, setInput] = useState();
  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="users">
          <Row>
            <Col sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Row className="">
                  <div className="my-4">
                    <Stack direction="horizontal" className="w-100 mt-5">
                      <SearchBarQuery setInput={setInput} />
                      <Modal
                        modalButton={<Button className="ms-auto btn btn-primary">+ New User</Button>}
                        title="Create New User"
                        body={<AdminSignupForm />}
                        size="lg"
                        id="shared-access-modal"
                      />
                    </Stack>
                  </div>
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
                </Row>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
