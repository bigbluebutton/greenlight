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

import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Col, Dropdown, Nav, Row, Tab,
} from 'react-bootstrap';
import {
  TrashIcon, UserIcon, LockClosedIcon, ChevronDownIcon,
} from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import DeleteAccount from './DeleteAccount';
import AccountInfo from './AccountInfo';
import ChangePassword from '../password_management/ChangePassword';
import { useAuth } from '../../../contexts/auth/AuthProvider';

export default function Profile() {
  const currentUser = useAuth();

  const { t } = useTranslation();

  // The keys are those of the tab panes.
  const sections = [
    {
      key: 'first', Icon: UserIcon, label: t('user.account.account_info'), allowed: true,
    },
    {
      key: 'third', Icon: LockClosedIcon, label: t('user.account.change_password'), allowed: !currentUser.external_account,
    },
    {
      key: 'second', Icon: TrashIcon, label: t('user.account.delete_account'), allowed: true,
    },
  ].filter((section) => section.allowed);

  const [activeKey, setActiveKey] = useState('first');
  const current = sections.find((section) => section.key === activeKey);

  return (
    <div id="profile">
      <h3 className="py-5"> { t('user.profile.profile') } </h3>
      <Card className="border-0 card-shadow">
        <Tab.Container id="profile-wrapper" activeKey={activeKey} onSelect={(key) => setActiveKey(key)}>
          <Row>
            <Col xl={3}>
              <div id="profile-sidebar">
                {/* Sidebar list, from xl */}
                <Nav variant="pills" className="flex-column d-none d-xl-flex">
                  {sections.map(({ key, Icon, label }) => (
                    <Nav.Item key={key}>
                      <Nav.Link className="cursor-pointer text-muted" eventKey={key}>
                        <Icon className="hi-s text-muted me-3 pb-1" />
                        { label }
                      </Nav.Link>
                    </Nav.Item>
                  ))}
                </Nav>

                {/* Dropdown, below xl, as in the admin panel. */}
                <div className="section-nav-dropdown nav-pills d-xl-none" role="group" aria-label={t('user.profile.profile')}>
                  <Dropdown onSelect={(key) => setActiveKey(key)}>
                    <Dropdown.Toggle as="button" type="button" className="nav-link active w-100 d-flex align-items-center text-start">
                      {current && <current.Icon className="hi-s me-3" aria-hidden="true" />}
                      { current?.label }
                      <ChevronDownIcon className="hi-s ms-auto" aria-hidden="true" />
                    </Dropdown.Toggle>
                    <Dropdown.Menu>
                      {sections.map(({ key, Icon, label }) => (
                        <Dropdown.Item key={key} eventKey={key} active={key === activeKey} aria-current={key === activeKey ? 'true' : undefined}>
                          <Icon className="hi-s me-3" aria-hidden="true" />
                          { label }
                        </Dropdown.Item>
                      ))}
                    </Dropdown.Menu>
                  </Dropdown>
                </div>
              </div>
            </Col>
            <Col xl={9}>
              <Tab.Content className="p-3 ps-xl-0">
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
