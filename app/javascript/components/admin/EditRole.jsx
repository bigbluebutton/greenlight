import { ArrowCircleLeftIcon } from '@heroicons/react/outline';
import React from 'react';
import {
  Col, Container, Row, Tab, Card, Breadcrumb,
} from 'react-bootstrap';
import { Navigate, useNavigate, useParams } from 'react-router-dom';
import useRole from '../../hooks/queries/admin/roles/useRole';
import EditRoleForm from '../forms/admin/EditRoleForm';
import Spinner from '../shared_components/utilities/Spinner';
import AdminNavSideBar from './shared/AdminNavSideBar';

export default function EditRole() {
  const { roleId } = useParams();
  const navigate = useNavigate();
  const { data: role, isError } = useRole(roleId);

  if (isError) {
    return <Navigate to="/adminpanel/roles" replace />;
  }

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
                <Container>
                  <Row className="mt-1"><h3>Roles</h3></Row>
                  <Row className="mt-0 mb-1">
                    <Col order="first">
                      <Breadcrumb className="float-start">
                        <Breadcrumb.Item onClick={() => navigate('/adminpanel/roles')}>Roles</Breadcrumb.Item>
                        <Breadcrumb.Item active>{role?.name ?? 'Edit Role'}</Breadcrumb.Item>
                      </Breadcrumb>
                    </Col>
                    <Col order="last">
                      <div className="float-end cursor-pointer" aria-hidden="true" onClick={() => navigate('/adminpanel/roles')}>
                        <ArrowCircleLeftIcon className="hi-s" /> Back
                      </div>
                    </Col>
                  </Row>
                  <Row><hr className="w-100 mx-0" /></Row>
                  <Row className="my-2">
                    <Col>
                      {(!role && <Spinner />) || <EditRoleForm role={role} />}
                    </Col>
                  </Row>
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
