import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useDeleteRole({ role, onSettled }) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete(`/admin/roles/${role.id}.json`),
    {
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSuccess: () => {
        queryClient.invalidateQueries('getRoles');
        toast.success(`Role "${role.name}" deleted.`);
        navigate('/adminpanel/roles');
      },
      onSettled,
    },
  );
}
