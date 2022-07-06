import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useGenerateAccessCode(friendlyId) {
  const queryClient = useQueryClient();

  const generateAccessCode = (data) => axios.patch(`/api/v1/rooms/${friendlyId}/generate_access_code.json`, { bbb_role: data });

  const mutation = useMutation(generateAccessCode, {
    onSuccess: () => {
      queryClient.invalidateQueries('getAccessCodes');
      toast.success('Access code generated ');
    },
    onError: () => {
      toast.error('There was a problem completing that action. \n Please try again.');
    },
  });

  const handleGenerateAccessCode = (data) => mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});

  return { handleGenerateAccessCode, ...mutation };
}
