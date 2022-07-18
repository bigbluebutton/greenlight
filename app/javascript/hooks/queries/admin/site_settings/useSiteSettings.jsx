import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useSiteSettings() {
  return useQuery(
    'getSiteSettings',
    async () => axios.get('/site_settings.json').then((resp) => resp.data.data),
  );
}
