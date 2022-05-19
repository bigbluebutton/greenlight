import { useMutation } from 'react-query';
import axios from 'axios';

export default function newDeleteSession(friendlyId) {
  const deleteSharedAccess = (data) => {
    console.log(data);
    axios.delete(`/api/v1/shared_accesses/room/${friendlyId}.json`, { data });
  };

  const mutation = useMutation(deleteSharedAccess);

  return mutation;
}
