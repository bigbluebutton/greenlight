import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs,
} from 'react-bootstrap';
import ActiveUsers from './users/ActiveUsers';
import AdminNavSideBar from './shared/AdminNavSideBar';

export default function ManageUsers() {
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
                <Row className="pt-5">
                  <Tabs defaultActiveKey="active">
                    <Tab eventKey="active" title="Active">
                      <ActiveUsers />
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
