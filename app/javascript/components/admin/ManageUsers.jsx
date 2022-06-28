import React from 'react';
import { Row, Tab, Tabs } from 'react-bootstrap';
import ActiveUsers from './ActiveUsers';

export default function ManageUsers() {
  return (
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
  );
}
