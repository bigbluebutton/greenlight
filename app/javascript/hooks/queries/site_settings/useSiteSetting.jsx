import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useSiteSetting(names) {
  return useQuery(
    ['getSiteSettings', names],
    () => axios.get('/site_settings.json', { params: { names } }).then((resp) => resp.data.data),
  );
}
