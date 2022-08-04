import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useUpdateSiteSetting(name) {
  const queryClient = useQueryClient();

  const uploadPresentation = (data) => {
    let settings;

    if (name === 'BrandingImage') {
      settings = new FormData();
      settings.append('site_setting[value]', data);
    } else {
      settings = data;
    }

    return axios.patch(`/admin/site_settings/${name}.json`, settings);
  };

  return useMutation(
    uploadPresentation,
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
