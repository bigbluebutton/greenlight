import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useUpdateSiteSetting(name) {
  const queryClient = useQueryClient();

  // TODO - samuel: replace the create avatar form with this simple validation method
  const imageValidation = (image) => {
    const FILE_SIZE = 3_000_000;
    const SUPPORTED_FORMATS = 'image/jpeg|image/png|image/svg';

    if (image.size > FILE_SIZE) {
      throw new Error('File is too large');
    } else if (!image.type.match(SUPPORTED_FORMATS)) {
      throw new Error('File type is not supported');
    }
  };

  const uploadPresentation = (data) => {
    let settings;

    if (name === 'BrandingImage') {
      imageValidation(data);
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
        queryClient.invalidateQueries(['getSiteSettings', name]);
        queryClient.invalidateQueries('getSiteSettings');
        toast.success('Site settings updated');
      },
      onError: (e) => {
        toast.error(e.message);
      },
    },
  );
}
