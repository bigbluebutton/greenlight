import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useUpdateRole(roleId) {
  const queryClient = useQueryClient();

  return useMutation(
    (role) => axios.patch(`/admin/roles/${roleId}.json`, { role }),
    {
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSuccess: () => {
        toast.success('Role updated');
        queryClient.invalidateQueries('getRoles');
        queryClient.invalidateQueries(['getRole', roleId.toString()]);
      },
    },
  );
}
