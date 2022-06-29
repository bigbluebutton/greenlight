import React from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import Card from 'react-bootstrap/Card';
import {
  Col, Row, Tab,
} from 'react-bootstrap';
import AdminNavSideBar from './shared/AdminNavSideBar';

function usePath() {
  const { pathname: path } = useLocation();
  return path.split('/').at(-1);
}

export default function AdminPanel() {
  const activeKey = usePath();
  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey={activeKey}>
          <Row>
            <Col sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Outlet />
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
