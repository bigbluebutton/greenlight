import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Stack, Container,
} from 'react-bootstrap';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowCircleLeftIcon } from '@heroicons/react/outline';
import AdminNavSideBar from '../shared/AdminNavSideBar';
import AccountInfo from '../../users/AccountInfo';
import useUser from '../../../hooks/queries/users/useUser';
import Spinner from '../../shared/stylings/Spinner';

export default function EditUser() {
  const { userId } = useParams();
  const { isLoading, data: user } = useUser(userId);
  const navigate = useNavigate();

  if (isLoading) return <Spinner />;

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activekey="users">
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
                    <div className="ms-auto cursor-pointer" aria-hidden="true" onClick={() => navigate('/adminpanel/users')}>
                      <ArrowCircleLeftIcon className="hi-s" /> Back
                    </div>
                    {/* <ButtonLink to="/adminpanel/users" className="ms-auto">Back</ButtonLink> */}
                  </Stack>
                  <span className="text-muted mb-4"> Users/Edit </span>
                  <hr className="solid" />
                </Row>
                <Row className="mb-4">
                  <AccountInfo user={user} />
                </Row>
              </Col>
            </Row>
          </Container>
        </Tab.Container>
      </Card>
    </div>
  );
}
