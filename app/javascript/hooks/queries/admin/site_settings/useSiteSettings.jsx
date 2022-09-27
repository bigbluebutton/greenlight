import { useQuery } from 'react-query';
import axios from '../../../../helpers/Axios';

export default function useSiteSettings(names) {
  return useQuery(
    ['getSiteSettings', names],
    () => axios.get('/admin/site_settings.json', { params: { names } }).then((resp) => resp.data.data),
  );
}
