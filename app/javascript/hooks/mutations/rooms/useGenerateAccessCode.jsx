import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useGenerateAccessCode(friendlyId) {
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.patch(`/rooms/${friendlyId}/generate_access_code.json`, { bbb_role: data }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getAccessCodes');
        toast.success('Access code generated ');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
