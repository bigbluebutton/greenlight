import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useUpdateSiteSetting(settingName) {
  const queryClient = useQueryClient();

  return useMutation(
    // eslint-disable-next-line camelcase
    (site_setting) => axios.put(`/admin/site_settings/${settingName}.json`, { site_setting }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries('getSiteSettings');
        toast.success('Site setting update.');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
