import React from 'react';
import { Table } from 'react-bootstrap';
import useServerRooms from '../../hooks/queries/admin/server_rooms/useServerRooms';
import SortBy from '../shared/SortBy';
import ServerRoomRow from './ServerRoomRow';

export default function ServerRooms() {
  const { data: rooms } = useServerRooms();

  return (
    <>
      <h2> Server Rooms </h2>
      <div id="admin-server-rooms">
        <Table className="table-bordered border border-2" hover>
          <thead>
            <tr className="text-muted small">
              <th className="fw-normal border-end-0">Name <SortBy fieldName="name" /></th>
              <th className="fw-normal border-0">Owner <SortBy fieldName="length" /></th>
              <th className="fw-normal border-0">ID</th>
              <th className="fw-normal border-0">Participants <SortBy fieldName="visibility" /></th>
              <th className="fw-normal border-0">Status</th>
              <th className="border-start-0" aria-label="options" />
            </tr>
          </thead>
          <tbody className="border-top-0">
            {rooms?.length
              ? (
                rooms?.map((room) => <ServerRoomRow key={room.id} room={room} />)
              )
              : (
                <tr>
                  <td className="fw-bold">
                    No recordings found!
                  </td>
                </tr>
              )}
          </tbody>
        </Table>
      </div>
    </>
  );
}
