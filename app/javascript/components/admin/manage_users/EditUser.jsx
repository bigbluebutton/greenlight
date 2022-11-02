import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Stack, Container,
} from 'react-bootstrap';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeftCircleIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import AdminNavSideBar from '../AdminNavSideBar';
import AccountInfo from '../../users/user/AccountInfo';
import useUser from '../../../hooks/queries/users/useUser';
import Spinner from '../../shared_components/utilities/Spinner';

export default function EditUser() {
  const { t } = useTranslation();
  const { userId } = useParams();
  const { isLoading, data: user } = useUser(userId);
  const navigate = useNavigate();

  if (isLoading) return <Spinner />;

  return (
    <div id="admin-panel" className="pb-3">
      <h3 className="py-5"> { t('admin.admin_panel') } </h3>
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
                    <h3 className="mb-0">{ t('admin.manage_users.edit_user')}</h3>
                    <div className="ms-auto cursor-pointer" aria-hidden="true" onClick={() => navigate('/admin/users')}>
                      <ArrowLeftCircleIcon className="hi-s" /> { t('back') }
                    </div>
                  </Stack>
                  <span className="text-muted mb-4">{ t('admin.manage_users.users_edit_path') }</span>
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
