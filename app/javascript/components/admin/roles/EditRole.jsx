import { ArrowLeftCircleIcon } from '@heroicons/react/24/outline';
import React from 'react';
import {
  Col, Container, Row, Tab, Card, Breadcrumb,
} from 'react-bootstrap';
import { Navigate, useNavigate, useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import useRole from '../../../hooks/queries/admin/roles/useRole';
import EditRoleForm from './forms/EditRoleForm';
import Spinner from '../../shared_components/utilities/Spinner';
import AdminNavSideBar from '../AdminNavSideBar';
import {useAuth} from "../../../contexts/auth/AuthProvider";

export default function EditRole() {
  const { t } = useTranslation();
  const { roleId } = useParams();
  const navigate = useNavigate();
  const { data: role, isError } = useRole(roleId);
  const currentUser = useAuth();

  if (currentUser.permissions?.ManageRoles !== 'true') {
    return <Navigate to="/404" />;
  }

  if (isError) {
    return <Navigate to="/admin/roles" replace />;
  }

  return (
    <div id="admin-panel" className="pb-3">
      <h3 className="py-5">{ t('admin.admin_panel') }</h3>
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
                  <Row className="mt-1"><h3>{ t('admin.roles.roles')}</h3></Row>
                  <Row className="mt-0 mb-1">
                    <Col order="first">
                      <Breadcrumb className="float-start">
                        <Breadcrumb.Item onClick={() => navigate('/admin/roles')}>{ t('admin.roles.roles') }</Breadcrumb.Item>
                        <Breadcrumb.Item active>{role?.name ?? 'Edit Role'}</Breadcrumb.Item>
                      </Breadcrumb>
                    </Col>
                    <Col order="last">
                      <div className="float-end cursor-pointer" aria-hidden="true" onClick={() => navigate('/admin/roles')}>
                        <ArrowLeftCircleIcon className="hi-s" /> { t('back') }
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
