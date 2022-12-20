import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useLocales() {
  return useQuery(
    'getLocales',
    () => axios.get('/locales.json').then((resp) => resp.data.data),
  );
}
