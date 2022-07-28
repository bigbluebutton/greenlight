import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useSiteSettingAsync(name) {
  return useQuery(
    ['getSiteSettings', name],
    async () => {
      const promise = await axios.get(`/site_settings/${name}.json`);
      return promise.data.data;
    },
  );
}
