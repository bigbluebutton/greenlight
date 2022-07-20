import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useSiteSettings() {
  return useQuery(
    'getSiteSettings',
    () => axios.get('/admin/site_settings.json').then((resp) => resp.data.data),
  );
}
