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
  Col, Container, Row, Tab, Table,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { Navigate } from 'react-router-dom';
import useServerRooms from '../../../hooks/queries/admin/server_rooms/useServerRooms';
import ServerRoomRow from './ServerRoomRow';
import SearchBar from '../../shared_components/search/SearchBar';
import AdminNavSideBar from '../AdminNavSideBar';
import Pagination from '../../shared_components/Pagination';
import SortBy from '../../shared_components/search/SortBy';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import ServerRoomsRowPlaceHolder from './ServerRoomsRowPlaceHolder';
import NoSearchResults from '../../shared_components/search/NoSearchResults';
import EmptyServerRoomsList from '../../rooms/EmptyServerRoomsList';

export default function ServerRooms() {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState();
  const [page, setPage] = useState();
  const { isLoading, data: serverRooms } = useServerRooms(searchInput, page);
  const currentUser = useAuth();

  if (currentUser.permissions?.ManageRooms !== 'true') {
    return <Navigate to="/404" />;
  }

  return (
    <div id="admin-panel" className="pb-4">
      <h3 className="py-5"> { t('admin.admin_panel') } </h3>
      <Card className="border-0 card-shadow">
        <Tab.Container activeKey="server_rooms">
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
                    <h3> { t('admin.server_rooms.server_rooms') } </h3>
                  </div>
                  <div className="px-4 pt-4">
                    <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
                  </div>
                  {
                      (!searchInput && serverRooms?.data.length === 0)
                        ? (
                          <EmptyServerRoomsList />
                        ) : (

                          (searchInput && serverRooms?.data.length === 0)
                            ? (
                              <div className="mt-5">
                                <NoSearchResults text={t('room.search_not_found')} searchInput={searchInput} />
                              </div>
                            ) : (
                              <div className="p-4">

                                <Table id="server-rooms-table" className="table-bordered border border-2 mt-4 mb-0" hover responsive>
                                  <thead>
                                    <tr className="text-muted small">
                                      <th className="fw-normal border-end-0">{ t('admin.server_rooms.name') }<SortBy fieldName="name" /></th>
                                      <th className="fw-normal border-0">{ t('admin.server_rooms.owner') }<SortBy fieldName="users.name" /></th>
                                      <th className="fw-normal border-0">{ t('admin.server_rooms.room_id') }</th>
                                      <th className="fw-normal border-0">{ t('admin.server_rooms.participants') }</th>
                                      <th className="fw-normal border-0">{ t('admin.server_rooms.status') }</th>
                                      <th className="border-start-0" aria-label="options" />
                                    </tr>
                                  </thead>

                                  <tbody className="border-top-0">

                                    {
                                    isLoading
                                      ? (
                                        // eslint-disable-next-line react/no-array-index-key
                                        [...Array(10)].map((val, idx) => <ServerRoomsRowPlaceHolder key={idx} />)
                                      )
                                      : (
                                        serverRooms?.data.length
                                          && (
                                            serverRooms?.data.map((room) => <ServerRoomRow key={room.friendly_id} room={room} />)
                                          )
                                      )
                                  }
                                  </tbody>
                                  { (serverRooms?.meta?.pages > 1)
                                    && (
                                      <tfoot>
                                        <tr>
                                          <td colSpan={12}>
                                            <Pagination
                                              page={serverRooms?.meta?.page}
                                              totalPages={serverRooms?.meta?.pages}
                                              setPage={setPage}
                                            />
                                          </td>
                                        </tr>
                                      </tfoot>
                                    )}
                                </Table>
                              </div>
                            )
                        )
                    }
                </Container>
              </Tab.Content>
            </Col>
          </Row>
        </Tab.Container>
      </Card>
    </div>
  );
}
