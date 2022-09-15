import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useSiteSetting(name) {
  return useQuery(
    ['getSiteSettings', name],
    () => axios.get(`/site_settings/${name}.json`).then((resp) => resp.data.data)
  );
}
