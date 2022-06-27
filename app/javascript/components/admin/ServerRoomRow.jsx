import React from 'react';
import { DotsVerticalIcon } from '@heroicons/react/outline';
import { Stack } from 'react-bootstrap';

export default function ServerRoomRow({ room }) {
  return (
    <tr key={room.id} className="align-middle text-muted border border-2">
      <td className="border-end-0">
        <Stack>
          <span className="text-dark fw-bold"> { room.name } </span>
          <span> Ended: </span>
        </Stack>
      </td>
      <td className="border-0"> { room.owner }</td>
      <td className="border-0"> { room.friendly_id } </td>
      <td className="border-0"> - </td>
      <td className="border-0"> - </td>
      <td className="border-start-0">
        <DotsVerticalIcon className="hi-s text-muted" />
      </td>
    </tr>
  );
}
