import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Row, Tab,
} from 'react-bootstrap';
import AdminNavSideBar from './shared/AdminNavSideBar';

export default function Roles() {
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
                <h1>Roles</h1>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
