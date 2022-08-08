import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useUpdateSiteSetting(name) {
  const queryClient = useQueryClient();

  return useMutation(
    (siteSetting) => axios.patch(`/admin/site_settings/${name}.json`, { siteSetting }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getSiteSettings');
        toast.success('Site settings updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
