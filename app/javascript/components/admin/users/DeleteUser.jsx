import React from 'react';
import Card from 'react-bootstrap/Card';
import PropTypes from 'prop-types';
import {
  Row, Col, Tab, Stack, Container,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import ButtonLink from '../../shared/stylings/buttons/ButtonLink';
import AdminNavSideBar from '../shared/AdminNavSideBar';
import DeleteAccount from './DeleteAccount';
import useUser from '../../../hooks/queries/users/useUser';
import Spinner from '../../shared/stylings/Spinner';

export default function DeleteUser() {
  const { userId } = useParams();
  const { isLoading, data: user } = useUser(userId);

  if (isLoading) return <Spinner />;

  return (
    <div id="admin-panel" className="wide-background">
      <h2 className="my-5"> Administrator Panel </h2>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="users">
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
                    <h3 className="mb-0">Delete User</h3>
                    <ButtonLink to="/adminpanel/users" className="ms-auto">Back</ButtonLink>
                  </Stack>
                  <span className="text-muted mb-4"> Users/Delete </span>
                  <hr className="solid" />
                </Row>
                <Row className="mb-4">
                  <DeleteAccount user={user} />
                </Row>
              </Col>
            </Row>
          </Container>
        </Tab.Container>
      </Card>
    </div>
  );
}

DeleteUser.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.number.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
  }).isRequired,
};
