import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useDeleteAccessCode(friendlyId) {
  const queryClient = useQueryClient();

  return useMutation(
    (data) => axios.patch(`/rooms/${friendlyId}/remove_access_code.json`, { bbb_role: data }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getAccessCodes');
        toast.success('Removed access code');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
