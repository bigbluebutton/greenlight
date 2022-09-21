import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import axios from '../../../../helpers/Axios';

export default function useDeleteRole({ role, onSettled }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  return useMutation(
    () => axios.delete(`/admin/roles/${role.id}.json`),
    {
      onError: () => { toast.error(t('toast.error.problem_completing_action')); },
      onSuccess: () => {
        queryClient.invalidateQueries('getRoles');
        toast.success(t('toast.success.role.role_deleted'));
        navigate('/admin/roles');
      },
      onSettled,
    },
  );
}
