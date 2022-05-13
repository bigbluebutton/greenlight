import React from 'react';
import { useParams } from 'react-router-dom';
import useSharedUsers from '../../hooks/queries/shared_accesses/useSharedUsers';
import SharedAccessList from './SharedAccessList';
import SharedAccessEmpty from './SharedAccessEmpty';
import useRoom from '../../hooks/queries/rooms/useRoom';
import { RoomProvider } from '../../contexts/roomContext';

export default function SharedAccess() {
  const { friendlyId } = useParams();
  // TODO: samuel - roomContext could/should be used higher up the tree (in Rooms/Room)
  const { data: room } = useRoom(friendlyId);
  const { data: users } = useSharedUsers(friendlyId);

  return (
    <RoomProvider value={room}>
      {
        (users?.length)
          ? <SharedAccessList users={users} />
          : <SharedAccessEmpty />
      }
    </RoomProvider>
  );
}
