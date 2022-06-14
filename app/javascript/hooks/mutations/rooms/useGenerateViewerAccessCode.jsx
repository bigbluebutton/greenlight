import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useGenerateViewerAccessCode(friendlyId) {
  const queryClient = useQueryClient();

  const generateAccessCode = () => axios.patch(`/api/v1/rooms/${friendlyId}/viewer_access_code.json`);

  const mutation = useMutation(generateAccessCode, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRoom');
    },
  });

  const handleGenerateViewerAccessCode = () => {
    mutation.mutateAsync().catch(/* Prevents the promise exception from bubbling */() => {});
  };

  return { handleGenerateViewerAccessCode, ...mutation };
}
