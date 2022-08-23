import { useMutation } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useUpdateRolePermission() {
  return useMutation(
    (role) => axios.post('/admin/role_permissions.json', { role }),
    {
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSuccess: () => {
        toast.success('Role Permission updated');
      },
    },
  );
}
