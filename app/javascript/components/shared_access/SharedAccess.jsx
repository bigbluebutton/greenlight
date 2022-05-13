import React from 'react';
import { useParams } from 'react-router-dom';
import useSharedUsers from '../../hooks/queries/shared_accesses/useSharedUsers';
import SharedAccessList from './SharedAccessList';
import SharedAccessEmpty from './SharedAccessEmpty';

export default function SharedAccess() {
  const { friendlyId } = useParams();
  const { data: users } = useSharedUsers(friendlyId);

  return (
    (users?.length)
      ? <SharedAccessList users={users} />
      : <SharedAccessEmpty />
  );
}
