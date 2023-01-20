import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Stack, Container,
} from 'react-bootstrap';
import { useParams, useNavigate, Navigate } from 'react-router-dom';
import { ArrowLeftCircleIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import AdminNavSideBar from '../AdminNavSideBar';
import AccountInfo from '../../users/user/AccountInfo';
import useUser from '../../../hooks/queries/users/useUser';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function EditUser() {
  const { t } = useTranslation();
  const { userId } = useParams();
  const { isLoading, data: user } = useUser(userId);
  const navigate = useNavigate();
  const currentUser = useAuth();
  // Todo: Use PermissionChecker.
  if (currentUser.permissions?.ManageUsers !== 'true') {
    return <Navigate to="/404" />;
  }

  return (
    <div id="admin-panel" className="pb-3">
      <h3 className="py-5"> { t('admin.admin_panel') } </h3>
      <Card className="border-0 shadow-sm">
        <Tab.Container activekey="users">
          <Container className="admin-table">
            <Row>
              <Col className="px-0" sm={3}>
                <div id="admin-sidebar">
                  <AdminNavSideBar />
                </div>
              </Col>
              <Col className="px-0" sm={9}>
                <Tab.Content className="ps-0">
                  <Container className="admin-table p-0">
                    <div className="p-4 border-bottom">
                      <div className="d-inline-block">
                        <h3>{ t('admin.manage_users.edit_user')}</h3>
                      </div>
                      <Stack
                        className="d-inline-block float-end cursor-pointer pe-2 pt-2 text-muted"
                        aria-hidden="true"
                        onClick={() => navigate('/admin/users')}
                      >
                        <ArrowLeftCircleIcon className="hi-s" /> { t('back') }
                      </Stack>
                    </div>
                    {!isLoading && (
                      <div className="p-4">
                        <AccountInfo user={user} />
                      </div>
                    )}
                  </Container>
                </Tab.Content>
              </Col>
            </Row>
          </Container>
        </Tab.Container>
      </Card>
    </div>
  );
}
