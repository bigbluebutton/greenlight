import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import AdminNavSideBar from '../shared/AdminNavSideBar';

export default function EditUser() {
  const { userId } = useParams();
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
              <h3>Manage User/Edit</h3>{userId}
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
