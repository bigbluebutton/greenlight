import { useQuery } from 'react-query';
import axios from '../../../helpers/Axios';

export default function useRoomRecordingsProcessing(friendlyId) {
  return useQuery(
    'useRoomRecordingsProcessing',
    () => axios.get(`/rooms/${friendlyId}/recordings_processing.json`).then((resp) => resp.data.data),
  );
}
