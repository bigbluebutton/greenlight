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
    <div id="admin-panel" className="pb-3">
      <h3 className="py-5"> { t('admin.admin_panel') } </h3>
      <Card className="border-0 shadow-sm">
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
                  <div className="p-4">
                    <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
                    <Table className="table-bordered border border-2 mt-4 mb-0" hover responsive>
                      <thead>
                        <tr className="text-muted small">
                          <th className="fw-normal border-end-0">{ t('admin.server_rooms.name') }<SortBy fieldName="name" /></th>
                          <th className="fw-normal border-0">{ t('admin.server_rooms.owner') }<SortBy fieldName="user.name" /></th>
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
                                ? (
                                  serverRooms?.data.map((room) => <ServerRoomRow key={room.friendly_id} room={room} />)
                                )
                                : (
                                  <tr>
                                    <td className="fw-bold" colSpan="6">
                                      { t('room.no_rooms_found') }
                                    </td>
                                  </tr>
                                )
                            )
                        }

                      </tbody>
                    </Table>
                    {!isLoading
                      && (
                        <Pagination
                          page={serverRooms.meta.page}
                          totalPages={serverRooms.meta.pages}
                          setPage={setPage}
                        />
                      )}
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
