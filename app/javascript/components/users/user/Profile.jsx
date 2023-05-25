// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Nav, Row, Tab,
} from 'react-bootstrap';
import { TrashIcon, UserIcon, LockClosedIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import DeleteAccount from './DeleteAccount';
import AccountInfo from './AccountInfo';
import ChangePassword from '../password_management/ChangePassword';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function Profile() {
  const currentUser = useAuth();

  const { t } = useTranslation();

  return (
    <div id="profile">
      <h3 className="py-5"> { t('user.profile.profile') } </h3>
      <Card className="border-0 card-shadow">
        <Tab.Container id="profile-wrapper" defaultActiveKey="first">
          <Row>
            <Col sm={3}>
              <div id="profile-sidebar">
                <Nav variant="pills" className="flex-column">
                  <Nav.Item>
                    <Nav.Link className="cursor-pointer text-muted" eventKey="first">
                      <UserIcon className="hi-s text-muted me-3 pb-1" />
                      { t('user.account.account_info') }
                    </Nav.Link>
                  </Nav.Item>
                  { !currentUser.external_account
                    && (
                    <Nav.Item>
                      <Nav.Link className="cursor-pointer text-muted" eventKey="third">
                        <LockClosedIcon className="hi-s text-muted me-3 pb-1" />
                        { t('user.account.change_password') }
                      </Nav.Link>
                    </Nav.Item>
                    )}
                  { !currentUser.external_account
                    && (<Nav.Item>
                    <Nav.Link className="cursor-pointer text-muted" eventKey="second">
                      <TrashIcon className="hi-s text-muted me-3 pb-1" />
                      { t('user.account.delete_account') }
                    </Nav.Link>
                  </Nav.Item>)}
                </Nav>
              </div>
            </Col>
            <Col sm={9}>
              <Tab.Content className="p-3 ps-0">
                <Tab.Pane eventKey="first">
                  <AccountInfo user={currentUser} />
                </Tab.Pane>
                <Tab.Pane eventKey="second">
                  <DeleteAccount />
                </Tab.Pane>
                { !currentUser.external_account
                  && (
                  <Tab.Pane eventKey="third">
                    <ChangePassword />
                  </Tab.Pane>
                  )}
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
