import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Row, Col, Tab, Tabs, Stack, Button, Container,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import ActiveUsers from './ActiveUsers';
import AdminNavSideBar from '../AdminNavSideBar';
import Modal from '../../shared_components/modals/Modal';
import UserSignupForm from './forms/UserSignupForm';
import SearchBarQuery from '../../shared_components/search/SearchBarQuery';

export default function ManageUsers() {
  const { t } = useTranslation();
  const [input, setInput] = useState();
  return (
    <div id="admin-panel">
      <h3 className="py-5">{ t('admin.admin_panel') }</h3>
      <Card className="border-0 shadow-sm">
        <Tab.Container activeKey="users">
          <Row>
            <Col className="pe-0" sm={3}>
              <div id="admin-sidebar">
                <AdminNavSideBar />
              </div>
            </Col>
            <Col className="ps-0" sm={9}>
              <Tab.Content className="p-0">
                <Container className="admin-table p-0">
                  <div className="p-4 border-bottom">
                    <h3>{ t('admin.manage_users.manage_users') }</h3>
                  </div>
                  <div className="p-4">
                    <Stack direction="horizontal" className="mb-4">
                      <SearchBarQuery setInput={setInput} />
                      <Modal
                        modalButton={<Button variant="brand" className="ms-auto btn">{ t('admin.manage_users.add_new_user') }</Button>}
                        title={t('admin.manage_users.create_new_user')}
                        body={<UserSignupForm />}
                        size="lg"
                        id="shared-access-modal"
                      />
                    </Stack>
                    <Tabs defaultActiveKey="active">
                      <Tab eventKey="active" title={t('admin.manage_users.active')}>
                        <ActiveUsers input={input} />
                      </Tab>
                      <Tab eventKey="pending" title={t('admin.manage_users.pending')}>
                        Pending users component
                      </Tab>
                      <Tab eventKey="banned" title={t('admin.manage_users.banned')}>
                        Banned users component
                      </Tab>
                      <Tab eventKey="deleted" title={t('admin.manage_users.deleted')}>
                        Deleted users component
                      </Tab>
                    </Tabs>
                  </div>
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
