import React from 'react';
import { useParams } from 'react-router-dom';
import useSharedUsers from '../../hooks/queries/shared_accesses/useSharedUsers';
import SharedAccessList from './SharedAccessList';
import SharedAccessEmpty from './SharedAccessEmpty';
import Spinner from '../shared/stylings/Spinner';

export default function SharedAccess() {
  const { friendlyId } = useParams();
  const { isLoading, data: users } = useSharedUsers(friendlyId);

  if (isLoading) return <Spinner />;

  return (
    (users?.length)
      ? <SharedAccessList users={users} />
      : <SharedAccessEmpty />
  );
}
