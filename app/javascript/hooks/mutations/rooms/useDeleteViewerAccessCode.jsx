import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useDeleteViewerAccessCode(friendlyId) {
  const queryClient = useQueryClient();

  const deleteAccessCode = () => axios.patch(`/api/v1/rooms/${friendlyId}/remove_viewer_access_code.json`);

  const mutation = useMutation(deleteAccessCode, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRoom');
    },
  });

  const handleDeleteAccessCode = () => {
    mutation.mutateAsync().catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { handleDeleteAccessCode, ...mutation };
}
