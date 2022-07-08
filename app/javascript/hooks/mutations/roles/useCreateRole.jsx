import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useCreateRole({ onSettled }) {
  const queryClient = useQueryClient();

  return useMutation(
    (role) => axios.post('/admin/roles.json', { role }),
    {
      onSuccess: () => {
        toast.success('Role created');
        queryClient.invalidateQueries('getRoles');
      },
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSettled,
    },
  );
}
