import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useDeleteAccessCode(friendlyId) {
  const queryClient = useQueryClient();

  const deleteAccessCode = (data) => axios.patch(`/api/v1/rooms/${friendlyId}/remove_access_code.json`, data);

  const mutation = useMutation(deleteAccessCode, {
    onSuccess: () => {
      queryClient.invalidateQueries('getAccessCodes');
    },
  });

  const handleDeleteAccessCode = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});

  return { handleDeleteAccessCode, ...mutation };
}
