import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Stack, Container,
} from 'react-bootstrap';
import ButtonLink from '../../shared/stylings/buttons/ButtonLink';
import AdminNavSideBar from '../shared/AdminNavSideBar';
import UpdateUserForm from '../../forms/UpdateUserForm';
import SetAvatar from '../../users/SetAvatar';

export default function EditUser() {
  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Content activeKey="users">
          <Container className="admin-table">
            <Row>
              <Col sm={3}>
                <div id="admin-sidebar">
                  <AdminNavSideBar />
                </div>
              </Col>
              <Col sm={9}>
                <Row className="mb-4">
                  <Stack direction="horizontal" className="w-100 mt-4">
                    <h3 className="mb-0">Edit User</h3>
                    <ButtonLink to="/adminpanel/users" className="ms-auto">Back</ButtonLink>
                  </Stack>
                  <span className="text-muted mb-4"> Users/Edit </span>
                  <hr className="solid" />
                </Row>
                <Row className="mb-4">
                  <Col>
                    <UpdateUserForm />
                  </Col>
                  <Col>
                    <SetAvatar />
                  </Col>
                </Row>
              </Col>
            </Row>
          </Container>
        </Tab.Content>
      </Card>
    </div>
  );
}
