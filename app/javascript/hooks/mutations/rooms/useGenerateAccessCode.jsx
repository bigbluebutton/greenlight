import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

export default function useGenerateAccessCode(friendlyId) {
  const queryClient = useQueryClient();

  const generateAccessCode = (data) => axios.patch(`/api/v1/rooms/${friendlyId}/access_code.json`, data);

  const mutation = useMutation(generateAccessCode, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRoom');
    },
  });

  const handleGenerateAccessCode = (data) => {
    mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { handleGenerateAccessCode, ...mutation };
}
